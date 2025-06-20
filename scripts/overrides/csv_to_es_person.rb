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
      @json["title_t"] = title
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

    def citation
      if @row["Demographic Source(s)"]
        { "title" => @row["Demographic Source(s)"], "role" => "demographic source" }
      end
    end
  
    def title
      if @row["Primary field"].start_with?(",")
        @row["Primary field"][1...].strip
      else
        @row["Primary field"]
      end
    end

    def has_relation
      relations = []
      if parse_json("Cases Text")
        parse_json("Cases Text").each do |cases|
          # parse case from markdown entry: [case name](case id)
          relation = { "role" => "cases", "title" => parse_md_brackets(cases), "id" => parse_md_parentheses(cases) }
          relations << relation
        end
      end
      relations
    end

    def spatial
      places = []
      if parse_json("Birth Place")
        parse_json("Birth Place").each do |birth_place|
          place = { "name" => birth_place, "role" => "birth_place" }
          places << place
        end
      end
      places
    end

    def person
      people = []
      person_tags = parse_json("Tags")
      sex = parse_json("Sex")
      race = parse_json("Race or Ethnicity")
      people << {
        "role" => "person",
        "name" => title,
        "name_given" => @row["name_first"],
        "name_last" => @row["name_last"],
        "name_alternate" => @row["name_alternate"],
        "sex" => sex,
        "race" => race,
        "birth_date" => date,
        "trait1" => person_tags
      }
      case_roles = parse_json("case_role")
      case_sex = parse_json("person_sex")
      case_age = parse_json("person_age")
      case_race = parse_json("person_race")
      case_nationality = parse_json("person_nationality")
      case_note = parse_json("person_note")
      case_years = parse_json("person_case_year")
      case_tags = parse_json("person_tags")
      if case_roles
        case_roles.each do |case_role|
          if ["", "nan", "None"].include?(case_role)
            next
          end
          # parse case from markdown entry: [case name](case id)
          case_id = parse_md_parentheses(case_role.split("|")[2])
          case_name = parse_md_brackets(case_role.split("|")[2])
          if case_id && case_id.length > 0 && !people.find { |i| i["id"] == case_id }
            people << {
              "id" => case_id,
              "role" => match_with_case(case_roles, case_id),
              "sex" => match_with_case(case_sex, case_id),
              "age_category" => match_with_case(case_age, case_id),
              "race" => match_with_case(case_race, case_id),
              "nationality" => match_with_case(case_nationality, case_id),
              # this must be a single year, according to the airtable schema
              "order" => match_with_case(case_years, case_id).to_i,
              "note" => match_with_case(case_note, case_id),
              "trait1" => match_with_case(case_tags, case_id),
              "trait2" => case_name
            }
          end
        end
      end
      people
    end

    def rdf
      case_roles = []
      if @row["case_role"]
        JSON.parse(@row["case_role"]).each do |case_role|
          if case_role.include?("petitioner attorney") || case_role.include?("petitioner") || case_role.include?("respondent")
            #[person name](person id)|relationship|[case name](case id)
            case_id = parse_md_parentheses(case_role.split("|")[2])
            role = case_role.split("|")[1]
            original_person = case_role.split("|")[0]
            if case_id && role && original_person
              roles = search_case_roles(role, case_id, original_person)
            end
            case_roles.push(*roles)
          end
        end
      end
      if @row["RDF - person relationship person (from Relationships [join])"]
        JSON.parse(@row["RDF - person relationship person (from Relationships [join])"]).each do |person_info|
          if person_info
            if ["", "nan", "None"].include?(person_info)
              next
            end
            # field will be in format [person name](person id)|relationship|[person name](person id)
            data = person_info.split("|")
            name1_and_id = data[0]
            relationship = data[1]
            name2_and_id = data[2]
            #get names and id's out of brackets, quotes, and parentheses
            if name1_and_id != "[]()"
              # parse person from markdown entry: [person name](person id)
              person1_name = parse_md_brackets(name1_and_id)
              person1_id = parse_md_parentheses(name1_and_id)
            end
            if name2_and_id != "[]()"
              # parse person from markdown entry: [person name](person id)
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
          if ["", "nan", "None"].include?(person_info)
            next
          end
          # field will be in format [person name](person id)|relationship|[person name](person id)
          data = person_info.split("|")
          name1_and_id = data[0]
          relationship = data[1]
          name2_and_id = data[2]
          #get names and id's out of brackets, quotes, and parentheses
          # parse each person from markdown entry: [person name](person id)
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
      case_roles.uniq
    end

    def keywords
      # combines all tags, both those directly on the person and those tied to a specific case 
      tags = []
      if parse_json("Tags")
        tags << parse_json("Tags")
      end
      # these are case specific
      if parse_json("person_tags")
        parse_json("person_tags").each do |data|
          if data.split("|")[1]
            tag = data.split("|")[1].split(", ")
          end
          tags << tag
        end
      end
      # remove nils and duplicate values, return a single array
      tags.flatten.uniq.compact
    end

    def keywords2
      roles = []
      case_roles = parse_json("case_role")
      if case_roles
        case_roles.each do |case_role|
          if case_role.split("|")[1]
            # roles in form like "bound party, petitioner" should be ingested separately
            roles << case_role.split("|")[1].split(", ")
          end
        end
      end
      # remove duplicate roles
      roles.flatten.uniq
    end

    def text
      built_text = []
      @row.each do |column_name, value|
        new_value = (find_match(value).length > 0) ? find_match(value) : value
        #strip out quoted values and ids other than item itself
        built_text << new_value.to_s.gsub("\"", "").gsub(/(hc\..+?\d)\D/, "")
        # if column_name == "Primary field"
        #   50.times do 
        #     built_text << value.to_s.gsub("\"", "")
        #   end
        # end
      end
      return array_to_string(built_text, " ")
    end

    def search_case_roles(role, case_id, original_person)
      if !role || !case_id || !original_person
        #don't try to match regexes on nil
        return []
      end
      roles = []
      #construct regex based on the particular case role
      regexes = {}
      if role.include?("petitioner attorney")
        #respondent attorney, judge
        regexes["petitioner attorney"] = [/^.*?\brespondent attorney\b.*?\b#{case_id}\b.*?$/, /^.*?\bjudge\b.*?\b#{case_id}\b.*?$/]
      end
      if role.include?("petitioner")
        #judge
        regexes["petitioner"] = [/^.*?\bjudge\b.*?\b#{case_id}\b.*?$/]
      elsif role.include?("respondent")
        #judge
        regexes["respondent"] = [/^.*?\bjudge\b.*?\b#{case_id}\b.*?$/]
      end
      regexes.each do |person_role, regex_list|
        @csv.each do |row|
          #we *also* need to split the case role into JSON. this is getting too deep.
          #*does the regex match 
          #*after parsing with json, how to get the right one?
          regex_list.each do |regex|
            if regex.match?(row["case_role"])
              JSON.parse(row["case_role"]).select {|role| regex.match(role) }.each do |case_role|
                #problem, also need to know the corresponding role
                second_person = case_role.split("|")[0]
                relationship = (role == "petitioner attorney" && regex.to_s.include?("respondent attorney")) ? "attorney against" : "judged by"
                # parse person from markdown entry: [person name](person id)
                person1_name = parse_md_brackets(original_person)
                person1_id = parse_md_parentheses(original_person)
                person2_name = parse_md_brackets(second_person)
                person2_id = parse_md_parentheses(second_person)
                roles << {
                  "type" => "person_relationship",
                  "subject" => "#{person1_name} {#{person1_id}}",
                  "predicate" => relationship,
                  "object" => "#{person2_name} {#{person2_id}}"
                }
              end
            end
          end
        end
      end
      roles.uniq
    end

  end
  