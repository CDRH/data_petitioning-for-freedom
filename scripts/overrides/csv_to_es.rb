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
      @json["person_age_k"] = @row["Person Age Category"]
      @json["person_date_k"] = @row["Person Date"]
      @json["person_immigrant_k"] = @row["Person Immigrant Status"]
      @json["person_race_k"] = @row["Person Race"]
      @json["person_sex_k"] = @row["Person Sex"]
      @json["person_tags_k"] = @row["Person Tags"]
      @json["person_notes_k"] = @row["Person Notes"]
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
      @row["Case Summary"]
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
      @row["Keyword"]
    end

    def person
      # only includes name and case role, due to limitations of API
      list = []
      @row["Person Participants"].each_with_index { |name, index|
        person = { "name" => name, "role" => @row["Person case role"][index] }
        list << person
      }
      list
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
  
    def subjects
      @row["Petition Type"]
    end
  
    def title
      @row["Title"]
    end
  
    def topics
      @row["Petition Type"]
    end

		def spatial
			place = { "city" => @row["Location city"], "county" => @row["Location county"], "state" => @row["Location state"], "place_name" => @row["Location name"]}
			place
		end

    def text
      # TODO make any necessary modifications for 
      built_text = []
      @row.each do |column_name, value|
        built_text << value.to_s
      end
      return array_to_string(built_text, " ")
    end

  end
  