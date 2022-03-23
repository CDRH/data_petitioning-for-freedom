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
        @json["birthplace_k"] = @row["Birth Place"]
        @json["race_k"] = @row["Race or Ethnicity"]
        @json["sex_k"] = @row["Sex"]
        @json["name_given_k"] = @row["name_given"]
        @json["name_last_k"] = @row["name_last"]
        @json["name_alternate_k"] = @row["name_alternate"]
        @json["age_k"] = @row["Indicated Age Category (from Case Data [join])"]
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
  
    def get_id
      id = @row["unique_id"] ? @row["unique_id"] : "blank"
      id = id.split(" ")[0]
      id
    end

    def person
      # only includes name and case role, due to limitations of API
         { 
            "name" => @row["Participants"]
          }
    end
  
    def publisher
      "Center for Research in the Digital Humanities, University of Nebraska-Lincoln"
    end

    def source
      @row["Demographic Source(s)"]
    end
  
    def title
      @row["Participants"]
    end

  end
  