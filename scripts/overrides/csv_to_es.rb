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
			@json["court_k"] = @row["Court Type"]
			@json["outcome_k"] = @row["Petition Outcome"]
      @json["repository_k"] = @row["Repository"]
      @json["sites_of_significance_k"] = @row["Site(s) of Significance"]
      @json["points_of_law_k"] = @row["Points of Law Cited"]
      # I am leaving all the extra person fields as arrays for now, and Orchid can match them up with the correct people.
      # @json["person_age_k"] = @row["Person Age Category"]
      # @json["person_date_k"] = @row["Person Date"]
      # @json["person_immigrant_k"] = @row["Person Immigrant Status"]
      # @json["person_race_k"] = @row["Person Race"]
      # @json["person_sex_k"] = @row["Person Sex"]
      # @json["person_tags_k"] = @row["Person Tags"]
      # @json["person_notes_k"] = @row["Person Notes"]
      @json["person_relationships_k"] = @row["Person Relationships"]
      @json["person_related_to_k"] = @row["Person Relatees"]
		end
		
		def id
      get_id
    end
  
    def category
      "Cases"
    end
  
    def subcategory
      @row["Petition Type"]
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
      @row["Record Type"]
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
      @row["Tags"]
    end

    def person
      # only includes name and case role, due to limitations of API
      list = []
      if @row["Person Participants"]
        @row["Person Participants"].split(/; */).each_with_index { |name, index|
          person = { 
            "name" => name 
            # "role" => @row["Person Case Roles"].split(/; */)[index], 
            # "race_or_ethnicity" => @row["Person Race or Ethnicity"].split(/; */)[index],
            # "sex" => @row["Person Sex"].split(/; */)[index],
            # "date_of_birth" => @row["Person Date of Birth"].split(/; */)[index],
            # "additional_information" => {
            #   "age_category" => @row["Person Age Category"].split(/; */)[index],
            #   "immigrant_status" => @row["Person Immigrant Status"].split(/; */)[index],
            #   "tags" => @row["Person Tags"].split(/; */)[index],
            #   "notes" => @row["Person Notes"].split(/; */)[index]
          }
            if @row["Person Case Roles"]
              person["role"] = @row["Person Case Roles"].split(/; */)[index]
            end
            if @row["Person Race or Ethnicity"]
              person["race_or_ethnicity"] = @row["Person Race or Ethnicity"].split(/; */)[index]
            end
            if @row["Person Sex"]
              person["sex"] = @row["Person Sex"].split(/; */)[index]
            end
            if @row["Person Date of Birth"]
              person["date_of_birth"] = @row["Person Date of Birth"].split(/; */)[index]
            end
            person["additional_information"] = {}
            if @row["Person Age Category"]
              person["additional_information"]["age_category"] = @row["Person Age Category"].split(/; */)[index]
            end
            if @row["Person Immigrant Status"]
              person["additional_information"]["immigrant_status"] = @row["Person Immigrant Status"].split(/; */)[index]
            end
            if @row["Person Tags"]
              person["additional_information"]["tags"] = @row["Person Tags"].split(/; */)[index]
            end
            if @row["Person Notes"]
              person["additional_information"]["notes"] = @row["Person Notes"].split(/; */)[index]
            end
          list << person 
        }
      end
      if @row["Additional Parties"]
        @row["Additional Parties"].split(/; */).each { |name|
          person = { "name" => name, "role" => "Additional Party" }
          list << person
        }

      end
      list
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
  
    # def rights_holder
      # TODO
    # end
  
    # def rights_uri
      # TODO
    # end
  
    def source
      @row["Case Citation/Source"]
    end
  
    # def subjects
    #   @row["Petition Type"]
    # end
  
    def title
      @row["Title"]
    end
  
    # def topics
    #   @row["Petition Type"]
    # end

		def spatial
			place = { "city" => @row["Location city"], "county" => @row["Location county"], "state" => @row["Location state"], "place_name" => @row["Location name"]}

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
  