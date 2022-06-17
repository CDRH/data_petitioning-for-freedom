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
      if @row["Birth Place"]
        @json["birthplace_k"] = JSON.parse(@row["Birth Place"])
      end
      if @row["Race or Ethnicity"]
        @json["race_k"] = JSON.parse(@row["Race or Ethnicity"])
      end
      if @row["Sex"]
        @json["sex_k"] = JSON.parse(@row["Sex"])
      end
      @json["name_given_k"] = @row["name_given"]
      @json["name_last_k"] = @row["name_last"]
      if @row["name_alternate"]
        @json["name_alternate_k"] = @row["name_alternate"]
      end
      if @row["Indicated Age Category (from Case Data [join])"]
        @json["age_k"] = JSON.parse(@row["Indicated Age Category (from Case Data [join])"])
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
      @row["Primary Field"]
    end

    def relation
      #note this is still not a completed field
      @row["Cases"]
    end

    def spatial
      places = []
      if @row["Birth Place"]
        place = { "title" => JSON.parse(@row["Birth Place"]), "type" => "birth_place" }
        places << place
      end
      places
    end

    def keywords
      @row["Tags"]
    end

    def rdf
      case_roles = []
      if @row["RDF - person role case (from Case Role [join])"]
        JSON.parse(@row["RDF - person role case (from Case Role [join])"]).each do |person_info|
          data = person_info.split("|")
          name_and_id = data[0]
          role = data[1]
          case_and_id = data[2]
          #get names and id's out of brackets, quotes, and parentheses
          person_name = /\["(.*)"\]/.match(name_and_id)[1]
          person_id = /\((.*)\)/.match(name_and_id)[1]
          case_name = /\[(.*)\]/.match(case_and_id)[1]
          case_id = /\((.*)\)/.match(case_and_id)[1]
          subject = "#{person_name} {#{person_id}}"
          object = "#{case_name} {#{case_id}}"
          roles = { "type" => "case_role", "subject" => subject, "predicate" => role, "object" => object }
          case_roles << roles
        end
      end
      if @row["RDF - person relationship person (from Relationships [join])"]
        JSON.parse(@row["RDF - person relationship person (from Relationships [join])"]).each do |person_info|
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
  