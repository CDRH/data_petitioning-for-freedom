class CsvToEs
    # Note to add custom fields, use "assemble_collection_specific" from request.rb
    # and be sure to either use the _d, _i, _k, or _t to use the correct field type
    def array_to_string (array,sep)
      return array.map { |i| i.to_s }.join(sep)
    end

    def make_rdf_field(row, type, predicate)
      info = []
      if row && JSON.parse(row) != ""
        JSON.parse(row).each do |person_info|
          if person_info
            if ["", "nan", "None"].include?(person_info)
              next
            end
            data = person_info.split("|")
            #get name/id out of brackets/quotes/parentheses
            name_and_id = data[0]
            value_list = data[1].split(", ")
            case_and_id = data[2]
            person_name = parse_md_brackets(name_and_id)
            person_id = parse_md_parentheses(name_and_id)
            case_name = parse_md_brackets(case_and_id)
            case_id = parse_md_parentheses(case_and_id)
            subject = "#{person_name} {#{person_id}}"
            source = "#{case_name} {#{case_id}}"
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
      end
      info
    end
    ##########
    # FIELDS #
    ##########
    # Original fields:
    # https://github.com/CDRH/datura/blob/master/lib/datura/to_es/csv_to_es/fields.rb
    def assemble_collection_specific
			@json["outcome_k"] = check_and_parse("Petition Outcome")
      if @row["Point(s) of Law Cited"]
        @json["points_of_law_k"] = @row["Point(s) of Law Cited"]
      end
      @json["fate_of_bound_party_k"] = check_and_parse("Fate of Bound Party(s)")
      if @row["Item Type(s)"]
        @json["document_types_k"] = check_and_parse("Item Type(s)")
      end
			@json["court_k"] = @row["Court Type"]
      @json["repository_k"] = check_and_parse("Repository")
      @json["sites_of_significance_k"] = check_and_parse("Site(s) of Significance")
        # using this for people for now. may add more fields later.
      @json["petitioners_k"] = check_and_parse("Petitioners")

		end
		
		def id
      get_id
    end
  
    def category
      "Cases"
    end
  
    def category2
      check_and_parse("Petition Type")
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
      check_and_parse("Source Material(s)")
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
      check_and_parse("Tags")
    end

    def person
      people = []
      if @row["RDF - person role case (from Case Role [join])"] && @row["RDF - person role case (from Case Role [join])"] != ""
        JSON.parse(@row["RDF - person role case (from Case Role [join])"]).each do |person_info|
          if !person_info || ["", "nan", "None"].include?(person_info)
            next
          end
          data = person_info.split("|")
          role_list = data[1].split(", ")
          name_and_id = data[0]
          #get name/id out of brackets/quotes/parentheses
          name = parse_md_brackets(name_and_id)
          id = parse_md_parentheses(name_and_id)
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
          if !person_info
            next
          end
          data = person_info.split("|")
          name_and_id = data[0]
          role = data[1]
          case_and_id = data[2]
          #get names and id's out of brackets, quotes, and parentheses
          person_name = /\[(.*)\]/.match(name_and_id)[1] if /\[(.*)\]/.match(name_and_id)
          person_id = /\((.*)\)/.match(name_and_id)[1] if /\((.*)\)/.match(name_and_id)
          case_name = /\[(.*)\]/.match(case_and_id)[1] if /\[(.*)\]/.match(case_and_id)
          case_id = /\((.*)\)/.match(case_and_id)[1] if /\((.*)\)/.match(case_and_id)
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
      check_and_parse("Repository")
    end
  
    # def rights_uri
      # TODO
    # end
  
    def source
      @row["Case Citation(s)"]
    end

    def subjects
      check_and_parse("Document Type(s)")
    end
  
    def title
      @row["Petition or Case Title"]
    end

    def type
      check_and_parse("Court Type(s)")
    end

		def spatial
      places = []
      if @row["Court Location(s)"]
			  place = { "name" => check_and_parse("Court Location(s)"), "type" => "court_location" }
        place["short_name"] = check_and_parse("Court Name(s)")
        places << place
      end
      if @row["Site(s) of Significance"]
        place = { "name" => check_and_parse("Site(s) of Significance"), "type" => "site_of_significance" }
        places << place
      end
			places
		end

    def extent
      if @json["document_types_k"]
        @json["document_types_k"].count
      end
    end

    def text
      # built_text = []
      # @row.each do |column_name, value|
      #   built_text << value.to_s
      # end
      # return array_to_string(built_text, " ")
    end

    private

    def check_and_parse(key)
      # given a string, check for the matching field, parse JSON, and remove nil values
      if @row[key] && !@row[key].include?("#ERROR!")
        begin 
          JSON.parse(@row[key]).compact
        rescue
          nil
        end
      end
    end

    def parse_md_brackets(query)
      # given a markdown style link, parse the part in brackets
      if /\[(.*?)\]/.match(query)
        /\[(.*?)\]/.match(query)[1]
      else
        query
      end
    end
  
    def parse_md_parentheses(query)
      # given a markdown style link, parse the part in parentheses
      /\]\((.*?)\)/.match(query)[1] if /\]\((.*?)\)/.match(query)
    end

    def match_with_case(markdown_array, case_id)
      # make sure there is actual data in the array and not just nil, before looking for the match
      if markdown_array && (markdown_array.select{ |data| data && data.include?(case_id) }.length > 0)
        # find field value (i.e. age) that matches the given case id
        markdown_array.select{ |data| data && data.include?(case_id)}[0].split("|")[1]
      end
    end

  end
  