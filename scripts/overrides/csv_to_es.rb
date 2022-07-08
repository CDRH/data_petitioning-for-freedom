class CsvToEs
    # Note to add custom fields, use "assemble_collection_specific" from request.rb
    # and be sure to either use the _d, _i, _k, or _t to use the correct field type
    def array_to_string (array,sep)
      return array.map { |i| i.to_s }.join(sep)
    end

    def make_rdf_field(row, type, predicate)
      info = []
      JSON.parse(row).each do |person_info|
        if person_info
          data = person_info.split("|")
          #get name/id out of brackets/quotes/parentheses
          name_and_id = data[0]
          value_list = data[1].split(", ")
          case_and_id = data[2]
          name = /\["(.*)"\]/.match(data[0])[1]
          person_name = /\["(.*)"\]/.match(name_and_id)[1]
          person_id = /\((.*)\)/.match(name_and_id)[1]
          case_name = /\[(.*)\]/.match(case_and_id)[1]
          case_id = /\((.*)\)/.match(case_and_id)[1]
          subject = "#{person_name} {#{person_id}}"
          source = object = "#{case_name} {#{case_id}}"
          id = /\((.*)\)/.match(name_and_id)[1]
          value_list.each do |value|
            age = { 
              "type" => type, 
              "subject" => subject, 
              "predicate" => predicate,
              "object" => value,
              "source" => source
            }
            info << age
          end
        end
      end
      info
    end
    ##########
    # FIELDS #
    ##########
    # Original fields:
    # https://github.com/CDRH/datura/blob/master/lib/datura/to_es/csv_to_es/fields.rb
    def assemble_collection_specific
      if @row["Petition Outcome"]
			  @json["outcome_k"] = JSON.parse(@row["Petition Outcome"])
      end
      if @row["Point(s) of Law Cited"]
        @json["points_of_law_k"] = @row["Point(s) of Law Cited"]
      end
      if @row["Fate of Bound Party(s)"]
        @json["fate_of_bound_party_k"] = JSON.parse(@row["Fate of Bound Party(s)"])
      end
      if @row["Item Type(s)"]
        @json["document_types_k"] = JSON.parse(@row["Item Type(s)"])
      end
		end
		
		def id
      get_id
    end
  
    def category
      "Cases"
    end
  
    def subcategory
      if @row["Petition Type"]
        JSON.parse(@row["Petition Type"])
      end
    end
  
    # def creator
    #   # TODO
    # end
  
    # def contributor
    #   # TODO
    # end
  
    def date(before=false)
      Datura::Helpers.date_standardize(@row["Petition Date"], before)
    end

    def date_not_before
      if @row["Earliest Record Date"] && !@row["Earliest Record Date"].empty?
				Datura::Helpers.date_standardize(@row["Earliest Record Date"], false)
			else
				date
			end
    end

		def date_not_after
			if @row["Latest Record Date"] && !@row["Latest Record Date"].empty?
				Datura::Helpers.date_standardize(@row["Latest Record Date"], false)
			else
				date
			end
		end
  
    def description
      @row["Summary of Proceedings"]
    end
  
    def format
      if @row["Record Type(s)"]
        JSON.parse(@row["Record Type(s)"])
      end
    end
  
    def get_id
      id = @row["Case ID"] ? @row["Case ID"] : "blank"
      id = id.split(" ")[0]
      id
    end
  
    def language
      "en"
    end
    
    def keywords
      if @row["Tags"]
        JSON.parse(@row["Tags"])
      end
    end

    def person
      people = []
      if @row["RDF - person role case (from Case Role [join])"]
        JSON.parse(@row["RDF - person role case (from Case Role [join])"]).each do |person_info|
          data = person_info.split("|")
          role_list = data[1].split(", ")
          name_and_id = data[0]
          #get name/id out of brackets/quotes/parentheses
          name = /\["(.*)"\]/.match(name_and_id)[1]
          id = /\]\((.*)\)/.match(name_and_id)[1]
          role_list.each do |role|
            person = { "name" => name, "id" => id, "role" => role }
            people << person
          end
        end
      end
      if @row["Additional People"]
        @row["Additional People"].split("; ").each do |name|
          person = { "name" => name, "role" => "additional people" }
          people << person
        end
      end
      people
    end
  
    def publisher
      "Center for Research in the Digital Humanities, University of Nebraska-Lincoln"
    end

    def rdf
      info = []
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
          case_roles = { "type" => "case_role", "subject" => subject, "predicate" => role, "object" => object }
          info << case_roles
        end
      end
      if @row["bound_party_age"]
        info.concat(make_rdf_field(@row["bound_party_age"], "bound_party_age", "age"))
      end
      if @row["bound_party_race"]
        info.concat(make_rdf_field(@row["bound_party_race"], "bound_party_race", "race"))
      end
      if @row["bound_party_sex"]
        info.concat(make_rdf_field(@row["bound_party_sex"], "bound_party_sex", "sex"))
      end
      info
    end 
  
    def rights_holder
      if @row["Repository"]
        JSON.parse(@row["Repository"])
      end
    end
  
    # def rights_uri
      # TODO
    # end
  
    def source
      @row["Case Citation(s)"]
    end

    def subcategory
      if @row["Petition Type"]
        JSON.parse(@row["Petition Type"])
      end
    end

    def subjects
      if @row["Document Type(s)"]
        JSON.parse(@row["Document Type(s)"])
      end
    end
  
    def title
      @row["Petition or Case Title"]
    end

    def type
      if @row["Court Type(s)"]
        JSON.parse(@row["Court Type(s)"])
      end
    end

		def spatial
      places = []
      if @row["Court Location(s)"]
			  place = { "title" => JSON.parse(@row["Court Location(s)"]), "type" => "court_location" }
        if @row["Court Name(s)"]
          place["place_name"] = JSON.parse(@row["Court Name(s)"])
        end
        places << place
      end
      if @row["Site(s) of Significance"]
        place = { "title" => JSON.parse(@row["Site(s) of Significance"]), "type" => "site_of_significance" }
        places << place
      end
			places
		end

    def text
      built_text = []
      @row.each do |column_name, value|
        built_text << value.to_s
      end
      return array_to_string(built_text, " ")
    end

  end
  