class CsvToEsPerson < CsvToEs
    # Note to add custom fields, use "assemble_collection_specific" from request.rb
    # and be sure to either use the _d, _i, _k, or _t to use the correct field type
    def array_to_string (array,sep)
      return array.map { |i| i.to_s }.join(sep)
    end
    ##########
    # FIELDS #
    ##########
    # Original fields:
    # https://github.com/CDRH/datura/blob/master/lib/datura/to_es/csv_to_es/fields.rb
    def assemble_collection_specific
	  end
		
	  def id
      get_id
    end
  
    def category
      "People"
    end
  
    def date(before=false)
      Datura::Helpers.date_standardize(@row["Birth Date"], before)
    end

    def data_not_before
      Datura::Helpers.date_standardize(@row["Birth Date"], false)
    end
  
    def get_id
      id = @row["unique_id"] ? @row["unique_id"] : "blank"
      id = id.split(" ")[0]
      id
    end

    def publisher
      "Center for Research in the Digital Humanities, University of Nebraska-Lincoln"
    end

    def source
      if @row["Demographic Source(s)"]
        @row["Demographic Source(s)"]
      end
    end
  
    def title
      @row["Primary field"]
    end

    def relation
      if @row["Cases Text"]
        check_and_parse("Cases Text")
      end
    end

    def spatial
      places = []
      if @row["Birth Place"]
        place = { "name" => check_and_parse("Birth Place"), "role" => "birth_place" }
        places << place
      end
      places
    end

    def keywords
      @row["Tags"]
    end

    def person
      people = []
      person_tags = check_and_parse("Tags")
      people << {
        "role" => "person",
        "name_given" => @row["name_given"],
        "name_last" => @row["name_last"],
        "name_alternate" => check_and_parse("name_alternate"),
        "sex" => check_and_parse("Sex"),
        "race" => check_and_parse("Race or Ethnicity"),
        "trait1" => person_tags
      }
      case_roles = check_and_parse("case_role")
      case_sex = check_and_parse("person_sex")
      case_age = check_and_parse("person_age")
      case_race = check_and_parse("person_race")
      case_nationality = check_and_parse("person_nationality")
      case_note = check_and_parse("person_note")
      case_years = check_and_parse("person_case_year")
      case_tags = check_and_parse("person_tags")
      if case_roles
        case_roles.each_with_index do |case_role, index|
          case_id = parse_md_parentheses(case_role.split("|")[2])
          people << {
            "id" => case_id,
            "role" => match_with_case(case_roles, case_id),
            "sex" => match_with_case(case_sex, case_id),
            "age" => match_with_case(case_age, case_id),
            "race" => match_with_case(case_race, case_id),
            "nationality" => match_with_case(case_nationality, case_id),
            "order" => match_with_case(case_years, case_id),
            "note" => match_with_case(case_note, case_id),
            "trait1" => match_with_case(case_tags, case_id)
          }
        end
      end
      people
    end

    def rdf
      case_roles = []
      if @row["RDF - person relationship person (from Relationships [join])"]
        JSON.parse(@row["RDF - person relationship person (from Relationships [join])"]).each do |person_info|
          if person_info
            data = person_info.split("|")
            name1_and_id = data[0]
            relationship = data[1]
            name2_and_id = data[2]
            #get names and id's out of brackets, quotes, and parentheses
            if name1_and_id != "[]()"
              person1_name = parse_md_brackets(name1_and_id)
              person1_id = parse_md_parentheses(name1_and_id)
            end
            if name2_and_id != "[]()"
              person2_name = parse_md_brackets(name2_and_id)
              person2_id = parse_md_parentheses(name2_and_id)
            end
            subject = "#{person1_name} {#{person1_id}}"
            object = "#{person2_name} {#{person2_id}}"
            roles = { "type" => "person_relationship", "subject" => subject, "predicate" => relationship, "object" => object }
            case_roles << roles
          end
        end

      end
      # inverse relationships (i.e. mother of--daughter of)
      if @row["RDF - person relationship person (from Relationships [join] 2)"]
        JSON.parse(@row["RDF - person relationship person (from Relationships [join] 2)"]).each do |person_info|
          data = person_info.split("|")
          name1_and_id = data[0]
          relationship = data[1]
          name2_and_id = data[2]
          #get names and id's out of brackets, quotes, and parentheses
          if name1_and_id != "[]()"
            person1_name = parse_md_brackets(name1_and_id)
            person1_id = parse_md_parentheses(name1_and_id)
          end
          person2_name = parse_md_brackets(name2_and_id)
          person2_id = parse_md_parentheses(name2_and_id)
          subject = "#{person1_name} {#{person1_id}}"
          object = "#{person2_name} {#{person2_id}}"
          roles = { "type" => "person_relationship", "subject" => subject, "predicate" => relationship, "object" => object }
          case_roles << roles
        end
      end
      case_roles
    end

  end
  