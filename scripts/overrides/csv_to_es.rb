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
      
      @json["age_of_bound_party_k"] = @row["Age of Bound Party, If Stated"]
      @json["sex_of_bound_party_k"] = @row["Sex of Bound Party"]
      @json["minor_of_bound_party_k"] = @row["Bound Party a Minor?"]
      age_groups = []
      if @row["Age Category Indicated in Record"]
        bound_parties = @row["Age Category Indicated in Record"].split(/; */).each do |g|
          age_groups << g
        end
      end
      @json["age_category_of_bound_party_indicated_k"] = age_groups
      @json["race_of_bound_party_indicated_k"] = @row["Race or Ethnicity of Bound Party Indicated in Record"]
      @json["race_of_bound_party_determined_k"] = @row["Race of Bound Party as Determined by Team"]
      @json["bound_party_immigrant_k"] = @row["Immigrant Status Relevant to Petition?"]
      @json["nationality_of_bound_party_k"] = @row["If Immigrant Status Relevant, Country of Origin of Bound Party Listed or Implied in Record"]
      @json["fate_of_bound_party_k"] = @row["Fate of Bound Party"]
      @json["holding_party_relationship_to_bound_party_k"] = @row["Relationship of Bound Party to Holding Party"]
      @json["sex_of_holding_party_k"] = @row["Sex of Holding Party"]
      @json["race_of_holding_party_indicated_k"] = @row["Race or Ethnicity of Holding Party Indicated in Record"]
      @json["race_of_holding_party_determined_k"] = @row["Race of Holding Party as Determined by Team"]
      @json["petitioner_relationship_to_bound_party_k"] = @row["Petitioner Relationship to Bound Party"]
      @json["sex_of_petitioner_k"] = @row["Sex of Petitioner"]
      @json["race_of_petitioner_indicated_k"] = @row["Race or Ethnicity of Petitioner Indicated in Record"]
      @json["race_of_petitioner_determined_k"] = @row["Race of Petitioner as Determined by Team"]
			@json["court_k"] = @row["Court"]
			@json["additional_parties_k"] = @row["Additional Parties"]
			@json["outcome_k"] = @row["Outcome"]
			@json["additional_related_action_k"] = @row["Additional or Simultaneous Legal Action Related to the Habeas Petition"]
			@json["notes_k"] = @row["Notes"]
      @json["civil_criminal_k"] = @row["Civil or Criminal"]
      @json["repository_k"] = @row["Repository"]
      # @json["jurisdiction_k"] = @row["State"] ###Do we need a jurisdiction column?
      @json["county_k"] = @row["County"]
      @json["petition_secondary_type_k"] = @row["Petition Secondary Type"]
      @json["habeas_nature_k"] = @row["Nature of Habeas Dispute"]
		end
		
		def id
      get_id
    end
  
    def category
      "Cases"
    end
  
    def subcategory
      @row["Petition Category"]
    end
  
    # def creator
    #   # nested field
    #   { "name" => @row["Case Citation/Source"]}
    # end
  
    # def contributor
    #   # attributing everything to Katrina? leaving this aside
    #   [
    #       {
    #         "id": "kj",
    #         "name": "Katrina Jagodinsky",
    #         "role": ""
    #       }
    #     ]
    # end
  
    def date(before=true)
      Datura::Helpers.date_standardize(@row["Date"], before)
    end

		def date_not_after
			if @row["Latest Petition Date"] && !@row["Latest Petition Date"].empty?
				Datura::Helpers.date_standardize(@row["Latest Petition Date"], false)
			else
				date(false)
			end
		end
  
    # def description
    #   @row["Description"]
    # end
  
    # def format
    #   @row["Format"]
    # end
  
    def get_id
      id = @row["Case ID"] ? @row["Case ID"] : "blank"
      id = id.split(" ")[0]
      id
    end
  
    def language
      "en"
    end
    
    def keywords
      @row["Keyword"]
    end

    def person
      list = []
      if @row["Bound Party's Name(s): Last, First"]
        bound_parties = @row["Bound Party's Name(s): Last, First"].split(/; */).map do |p|
          { "name" => p, "role" => "Bound party" }
        end
        bound_parties.each do |p|
          list << p
        end
      end
      if @row["Petitioner Name (if Not the Bound Party): Last, First"]
        petitioners = @row["Petitioner Name (if Not the Bound Party): Last, First"].split(/; */).map do |p|
          { "name" => p, "role" => "Petitioners" }
        end
        petitioners.each do |p|
          list << p
        end
      end
      if @row["Petitioning Attorney Name-If Known: Last, First"]
        petitioning_attorneys = @row["Petitioning Attorney Name-If Known: Last, First"].split(/; */).map do |p|
          { "name" => p, "role" => "Petitioning attorney" }
        end
        petitioning_attorneys.each do |p|
          list << p
        end
      end
      if @row["Defendant Attorney Name-If Known: Last, First"]
        petitioning_attorneys = @row["Defendant Attorney Name-If Known: Last, First"].split(/; */).map do |p|
          { "name" => p, "role" => "Petitioning attorney" }
        end
        petitioning_attorneys.each do |p|
          list << p
        end
      end
      if @row["Name of Holding Party-If Known: Last, First"]
        holding_parties = @row["Name of Holding Party-If Known: Last, First"].split(/; */).map do |p|
          { "name" => p, "role" => "Holding party" }
        end
        holding_parties.each do |p|
          list << p
        end
      end
      if @row["Presiding Judge Name-If Known: Last, First"]
        judge = @row["Presiding Judge Name-If Known: Last, First"].split(/; */).map do |p|
          { "name" => p, "role" => "Judge" }
        end
        judge.each do |p|
          list << p
        end
      end
      if @row["Additional Parties Named in Document: Last, First"]
        additional_parties = @row["Additional Parties Named in Document: Last, First"].split(/; */).map do |p|
          { "name" => p, "role" => "Additional party" }
        end
        additional_parties.each do |p|
          list << p
        end
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
      #is this the correct version?
      "Center for Research in the Digital Humanities, University of Nebraska-Lincoln"
    end
  
    # def rights_holder
    #   # @row["Rights"]
		# 	# below may not be correct
		# 	@row["Repository"]
    # end
  
    def rights_uri
      # TODO
    end
  
    def source
      @row["Case Citation/Source"]
    end
  
    def subjects
      @row["Petition Type"]
    end
  
    def title
      @row["Case Name for Doc Title"]
    end
  
    def topics
      @row["Petition Type"]
    end

		def spatial
			place = { "city" => @row["City"], "county" => @row["County"], "state" => @row["State"], "place_name" => @row["Court"]}
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
  