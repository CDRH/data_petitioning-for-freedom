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
      @json["birthplace_k"] = check_and_parse(@row["Birth Place"])
      @json["race_k"] = check_and_parse(@row["Race or Ethnicity"])
      @json["sex_k"] = check_and_parse(@row["Sex"])
      @json["name_given_k"] = @row["name_given"]
      @json["name_last_k"] = @row["name_last"]
      if @row["name_alternate"]
        @json["name_alternate_k"] = @row["name_alternate"]
      end
      @json["age_k"] = check_and_parse(@row["Indicated Age Category (from Case Data [join])"])
      if @row["person_case_year"]
        @json["case_year_k"] = JSON.parse(@row["person_case_year"]).select{|i| i.class == String}
      end
      if @row["person_nationality"]
        @json["nationality_k"] = JSON.parse(@row["person_nationality"]).collect {|i| i.split("|")[1] if i }[0]
      end
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
        JSON.parse(@row["Cases Text"])
      end
    end

    def spatial
      places = []
      if @row["Birth Place"]
        place = { "name" => JSON.parse(@row["Birth Place"]), "type" => "birth_place" }
        places << place
      end
      places
    end

    def keywords
      @row["Tags"]
    end

    def person
    end

    def rdf
      case_roles = []
      if @row["RDF - person role case (from Case Role [join])"]
        JSON.parse(@row["RDF - person role case (from Case Role [join])"]).each do |person_info|
          if person_info
            data = person_info.split("|")
            name_and_id = data[0]
            role_list = data[1].split(", ")
            case_and_id = data[2]
            #get names and id's out of brackets, quotes, and parentheses
            person_name = /\["(.*)"\]/.match(name_and_id)[1] if /\["(.*)"\]/.match(name_and_id)
            person_id = /\((.*)\)/.match(name_and_id)[1] if /\((.*)\)/.match(name_and_id)
            case_name = /\[(.*)\]/.match(case_and_id)[1] if /\[(.*)\]/.match(case_and_id)
            case_id = /\((.*)\)/.match(case_and_id)[1] if /\((.*)\)/.match(case_and_id)
            role_list.each do |role|
              subject = "#{person_name} {#{person_id}}"
              object = "#{case_name} {#{case_id}}"
              roles = { "type" => "case_role", "subject" => subject, "predicate" => role, "object" => object }
              case_roles << roles
            end
          end
        end
      end
      if @row["RDF - person relationship person (from Relationships [join])"]
        JSON.parse(@row["RDF - person relationship person (from Relationships [join])"]).each do |person_info|
          if person_info
            data = person_info.split("|")
            name1_and_id = data[0]
            relationship = data[1]
            name2_and_id = data[2]
            #get names and id's out of brackets, quotes, and parentheses
            if name1_and_id != "[]()"
              person1_name = /\["(.*)"\]/.match(name1_and_id)[1]
              person1_id = /\((.*)\)/.match(name1_and_id)[1]
            end
            if name2_and_id != "[]()"
              person2_name = /\["(.*)"\]/.match(name2_and_id)[1]
              person2_id = /\((.*)\)/.match(name2_and_id)[1]
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
            person1_name = /\["(.*)"\]/.match(name1_and_id)[1]
            person1_id = /\((.*)\)/.match(name1_and_id)[1]
          end
          person2_name = /\["(.*)"\]/.match(name2_and_id)[1]
          person2_id = /\((.*)\)/.match(name2_and_id)[1]
          subject = "#{person1_name} {#{person1_id}}"
          object = "#{person2_name} {#{person2_id}}"
          roles = { "type" => "person_relationship", "subject" => subject, "predicate" => relationship, "object" => object }
          case_roles << roles
        end
      end
      case_roles
    end 

  end
  