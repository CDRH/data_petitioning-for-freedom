class CsvToEs
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
			@json["outcome_k"] = JSON.parse(@row["Petition Outcome"])
      @json["points_of_law_k"] = @row["Point(s) of Law Cited"]
      @json["fate_of_bound_party_k"] = JSON.parse(@row["Fate of Bound Party(s)"])
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
      @row["Notes"]
    end
  
    def format
      if @row["Record Type"]
        JSON.parse(@row["Record Type"])
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
          role = data[1]
          name_and_id = data[0]
          #get name/id out of brackets/quotes/parentheses
          name = /\["(.*)"\]/.match(name_and_id)[1]
          id = /\((.*)\)/.match(name_and_id)[1]
          person = { "name" => name, "id" => id, "role" => role }
          people << person
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
  

    def places
      places = []
      if @row["State/Territory"]
        state = @row["State/Territory"]
        places << state
        if @row["County"]
          county = @row["County"] + " County, " + @row["State/Territory"]
          places << county
        end
        if @row["City"]
          city = @row["City"] + ", " + @row["State/Territory"]
          places << city
        end
      end
      places
    end
  
    def publisher
      "Center for Research in the Digital Humanities, University of Nebraska-Lincoln"
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
      case_roles
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
      @row["Case Citation"]
    end

    def subcategory
      if @row["Petition Type"]
        JSON.parse(@row["Petition Type"])
      end
    end
  
    def title
      @row["Petition or Case Title"]
    end

    def type
      if @row["Court Type"]
        JSON.parse(@row["Court Type"])
      end
    end

		def spatial
      place = []
      if @row["Court Location(s)"]
			  place = { "title" => JSON.parse(@row["Court Location(s)"]), "type" => "court_location" }
      end
      if @row["Site(s) of Significance"]
        place = { "title" => @row["Site(s) of Significance"], "type" => "site_of_significance" }
      end
			place
		end

    def text
      built_text = []
      @row.each do |column_name, value|
        built_text << value.to_s
      end
      return array_to_string(built_text, " ")
    end

  end
  