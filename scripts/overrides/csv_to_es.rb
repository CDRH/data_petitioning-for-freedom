class CsvToEs
    # Note to add custom fields, use "assemble_collection_specific" from request.rb
    # and be sure to either use the _d, _i, _k, or _t to use the correct field type
  
    ##########
    # FIELDS #
    ##########
    # Original fields:
    # https://github.com/CDRH/datura/blob/master/lib/datura/to_es/csv_to_es/fields.rb
  
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
      @row["Artist/Creator"]
      if @row["Artist/Creator"]
        @row["Artist/Creator"].split("; ").map do |p|
          { "name" => p }
        end
      end
    end
  
    def contributor
      # nested field
      if @row["Contributor"]
        @row["Contributor"].split("; ").map do |p|
          { "name" => p }
        end
      end
    end
  
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
  
    def format
      @row["Format"]
    end
  
    def get_id
      @row["Filename"]
    end
  
    def language
      @row["Language"]
    end
  
    def places
      @row["Coverage"]
    end
  
    def publisher
      #is this the correct version?
      @row["Repository"]
    end
  
    def rights_holder
      @row["Rights"]
    end
  
    def rights_uri
      # TODO
    end
  
    def source
      @row["Case Citation/Source"]
    end

  
    def subjects
      [
        @row['Subject#1$1'],
        @row['Subject#1$2'],
        @row['Subject#1$3'],
        @row['Subject#1$4'],
        @row['Subject#1$5'],
        @row['Subject#1$6'],
        @row['Subject#1$7']
      ].join(", ")
    end
  
    def title
      @row["Case Name"]
    end
  
    def topics
      @row["Petition Type"]
    end
		#would it be better to use person.name and person.role?
		def bound_party_name_k
			@row["Bound Party's Name(s): Last, First"]
		end

		def petitioner_name_k
			@row["Petitioner Name (if Not the Bound Party): Last, First"]
		end

		def relationship_to_bound_party_k
			@row["Petitioner Relationship to Bound Party"]
		end

		def petitioning_attorney_name_k
			@row["Petitioning Attorney Name-If Known: Last, First (if multiple names separate with a semi-colon; if illegible, insert \"illegible\")"]
		end

		def judge_name_k
			@row["Presiding Judge Name-If Known: Last, First"]
		end

		def court_k
			@row["Court"]
		end

		def spatial.city
			@row["City"]
		end

		def spatial.county
			@row["County"]
		end

		def spatial.state
			@row["State/Territory"]
		end

		def sex_k
			@row["Sex of Bound Party"]
		end

		def minor_k
			@row["Bound Party a Minor? "]
		end

		def age_k
			@row["Age of Bound Party, If Stated"]
		end

		def age_category_indicated_k
			@row["Age Category Indicated in Record (insert any descriptive term used in record pertaining to age: \"child\" \"minor\" \"infant\" \"adult\")"]
		end

		def race_category_indicated_k
			@row["Race or Ethnicity Indicated in Record (insert any racial/ethnic category spelled out in document and separate multiple terms or words with a semicolon; insert \"None\" if no racial categories are used)"]
		end

		def race_category_determined_k
			@row["Race of Bound Party as Determined by Team (may be same as listed in record)"]
		end

		def immigrant_k
			@row["Immigrant?"]
		end

		def nationality_k
			@row["Nationality/Country of Origin as Listed or Implied in Record"]
		end

		def relationship_to_holding_party_k
			@row["Relationship of Bound Party to Holding Party (Bound Party is ______ Holding Party)"]
		end

		def holding_party_name_k
			@row["Name of Person Holding Bound Party-If Known: Last, First"]
		end

		def additional_parties_k
			@row["Additional Parties Named in Document (Last, First); separate parties with a semicolon"]
		end

		def outcome_k
			@row["Outcome"]
		end

		def additional_related_action_k
			@row["Additional or Simultaneous Legal Action Related to the Habeas Petition"]
		end

		def notes_k
			@row["Comments/notes"]
		end
  end
  