class CsvToEs
    # Note to add custom fields, use "assemble_collection_specific" from request.rb
    # and be sure to either use the _d, _i, _k, or _t to use the correct field type
  
    ##########
    # FIELDS #
    ##########
    # Original fields:
    # https://github.com/CDRH/datura/blob/master/lib/datura/to_es/csv_to_es/fields.rb
    def assemble_collection_specific
			bound_party = {
				"name" => @row["Bound Party's Name(s): Last, First"],
				"age" => @row["Age of Bound Party, If Stated"],
				"sex" => @row["Sex of Bound Party"],
				"minor" => @row["Bound Party a Minor? "],
				"age_category_indicated" => @row["Age Category Indicated in Record (insert any descriptive term used in record pertaining to age: \"child\" \"minor\" \"infant\" \"adult\")"],
				"race_category_indicated" => @row["Race or Ethnicity Indicated in Record (insert any racial/ethnic category spelled out in document and separate multiple terms or words with a semicolon; insert \"None\" if no racial categories are used)"],
				"race_category_determined" => @row["Race of Bound Party as Determined by Team (may be same as listed in record)"],
				"immigrant" => @row["Immigrant?"],
				"nationality" => @row["Nationality/Country of Origin as Listed or Implied in Record"],
				"relationship_to_holding_party" => @row["Relationship of Bound Party to Holding Party (Bound Party is ______ Holding Party)"]
			}
			petitioner =  {
				"name" => @row["Petitioner Name (if Not the Bound Party): Last, First"],
				"relationship" => @row["Petitioner Relationship to Bound Party"]
			}
			petitioning_attorney = {
				"name" => @row["Petitioning Attorney Name-If Known: Last, First (if multiple names separate with a semi-colon; if illegible, insert \"illegible\")"]
			}
			judge = { "name" => @row["Presiding Judge Name-If Known: Last, First"] }
			holding_party = { "name" => @row["Name of Person Holding Bound Party-If Known: Last, First"] }
			@json["bound_party_k"] = bound_party
			@json["petitioner_k"] = petitioner
			@json["petitioning_attorney_k"] = petitioning_attorney
			@json["judge_k"] = judge
			@json["holding_party_k"] = holding_party
			@json["court_k"] = @row["Court"]
			@json["additional_parties_k"] = @row["Additional Parties Named in Document (Last, First); separate parties with a semicolon"]
			@json["outcome_k"] = @row["Outcome"]
			@json["additional_related_action_k"] = @row["Additional or Simultaneous Legal Action Related to the Habeas Petition"]
			@json["notes_k"] = @row["Comments/notes"]
		end
		
		def id
      @row["Case ID: hc.case.0000.000"]
    end
  
    def category
      "Cases"
    end
  
    # def subcategory
    #   @row["Section"]
    # end
  
    def creator
      # nested field
      { "name" => @row["Case Citation/Source"]}
    end
  
    # def contributor
    #   # nested field
    #   if @row["Contributor"]
    #     @row["Contributor"].split("; ").map do |p|
    #       { "name" => p }
    #     end
    #   end
    # end
  
    def date(before=true)
      Datura::Helpers.date_standardize(@row["Earliest Petition Date (YYYY-MM-DD)"], before)
    end

		def date_not_after
			if @row["Latest Petition Date (YYYY-MM-DD)"] && !@row["Latest Petition Date (YYYY-MM-DD)"].empty?
				Datura::Helpers.date_standardize(@row["Latest Petition Date (YYYY-MM-DD)"], false)
			else
				date(false)
			end
		end
  
    def description
      @row["Description"]
    end
  
    # def format
    #   @row["Format"]
    # end
  
    def get_id
      @row["Case ID: hc.case.0000.000"] ? @row["Case ID: hc.case.0000.000"] : "blank"
    end
  
    def language
      "en"
    end
  
    def places
      @row["State/Territory"]
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
      @row["Case Citation/Source"]
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
			place = { "city" => @row["City"], "county" => @row["County"], "state" => @row["State/Territory"]}
			place
		end

  end
  