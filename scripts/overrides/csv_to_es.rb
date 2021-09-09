class CsvToEs
    # Note to add custom fields, use "assemble_collection_specific" from request.rb
    # and be sure to either use the _d, _i, _k, or _t to use the correct field type
  
    ##########
    # FIELDS #
    ##########
    # Original fields:
    # https://github.com/CDRH/datura/blob/master/lib/datura/to_es/csv_to_es/fields.rb
    def assemble_collection_specific
			# bound_party_k = {
			# 	"name" => @row["Bound Party Name"],
			# 	"age" => @row["Bound Party Age"],
			# 	"sex" => @row["Bound Party Sex"],
			# 	"minor" => @row["Bound Party Minor"],
			# 	"age_category_indicated" => @row["Age Category Indicated"],
			# 	"race_category_indicated" => @row["Race Indicated"],
			# 	"race_category_determined" => @row["Race Determined"],
			# 	"immigrant" => @row["Bound Party Immigrant"],
			# 	"nationality" => @row["Bound Party Nationality"],
			# 	"relationship_to_holding_party" => @row["Relationship To Holding Party"]
			# }
			# petitioner_k =  {
			# 	"name" => @row["Petitioner Name"],
			# 	"relationship" => @row["Relationship to Bound Party"]
			# }
			# petitioning_attorney_k = {
			# 	"name" => @row["Petitioning Attorney Name"]
			# }
			# judge_k = { "name" => @row["Judge Name"] }
			# holding_party_k = { "name" => @row["Holding Party Name"] }
			# @json["bound_party_k"] = bound_party_k
			# @json["petitioner_k"] = petitioner_k
			# @json["petitioning_attorney_k"] = petitioning_attorney_k
			# @json["judge_k"] = judge_k
			# @json["holding_party_k"] = holding_party_k
      @json["bound_party_age_k"] = @row["Bound Party Age"]
      @json["bound_party_sex_k"] = @row["Bound Party Sex"]
      @json["bound_party_minor_k"] = @row["Bound Party Minor"]
      @json["bound_party_age_category_indicated_k"] = @row["Age Category Indicated"]
      @json["bound_party_race_indicated_k"] = @row["Race Indicated"]
      @json["bound_party_race_determined_k"] = @row["Race Determined"]
      @json["bound_party_immigrant_k"] = @row["Bound Party Immigrant"]
      @json["bound_party_nationality_k"] = @row["Bound Party Nationality"]
      @json["bound_party_relationship_to_holding_party_k"] = @row["Relationship To Holding Party"]
      @json["petitioner_relationship_to_bound_party_k"] = @row["Relationship To Bound Party"]
			@json["court_k"] = @row["Court"]
			@json["additional_parties_k"] = @row["Additional Parties"]
			@json["outcome_k"] = @row["Outcome"]
			@json["additional_related_action_k"] = @row["Additional Related Action"]
			@json["notes_k"] = @row["Notes"]
		end
		
		def id
      @row["Case ID"]
    end
  
    def category
      "Cases"
    end
  
    # def subcategory
    #   @row["Section"]
    # end
  
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
      Datura::Helpers.date_standardize(@row["Earliest Date"], before)
    end

		def date_not_after
			if @row["Latest Date"] && !@row["Latest Date"].empty?
				Datura::Helpers.date_standardize(@row["Latest Date"], false)
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
      @row["Case ID"] ? @row["Case ID"] : "blank"
    end
  
    def language
      "en"
    end

    def person
      list = []
      bound_party = { "name" => @row["Bound Party Name"], "role" => "bound_party"}
      list << bound_party
      if @row["Petitioner Name"]
        petitioner = { "name" => @row["Petitioner Name"], "role" => "petitioner"}
        list << petitioner
      end
      if @row["Petitioning Attorney Name"]
        petitioning_attorney = { "name" => @row["Petitioning Attorney Name"], "role" => "attorney_petitioner"}
        list << petitioning_attorney
      end
      if @row["Holding Party Name"]
        holding_party = { "name" => @row["Holding Party Name"], "role" => "holding_party"}
        list << holding_party
      end
      if @row["Judge Name"]
        judge = { "name" => @row["Bound Party Name"], "role" => "judge"}
        list << judge
      end
      if @row["Additional Parties"]
        additional_parties = @row["Additional Parties"].split("; ").map do |p|
          { "name" => p, "role" => "additional party" }
        end
        additional_parties.each do |p|
          list << p
        end
      end
      list
    end
  
    def places
      places = []
      if @row["State"]
        state = @row["State"]
        places << state
        if @row["County"]
          county = @row["County"] + " County, " + @row["State"]
          places << county
        end
        if @row["City"]
          city = @row["City"] + ", " + @row["State"]
          places << city
        end
      end
      places
    end
  
    def publisher
      #is this the correct version?
      @row["Repository"]
    end
  
    def rights_holder
      # @row["Rights"]
			# below may not be correct
			@row["Repository"]
    end
  
    def rights_uri
      # TODO
    end
  
    def source
      @row["Case Citation Or Source"]
    end
  
    def subjects
      @row["Petition Type"]
    end
  
    def title
      @row["Case Name"]
    end
  
    def topics
      @row["Petition Type"]
    end

		def spatial
			place = { "city" => @row["City"], "county" => @row["County"], "state" => @row["State"], "place_name" => @row["Court"]}
			place
		end

  end
  