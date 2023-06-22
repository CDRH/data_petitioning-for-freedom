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
            #
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
		end
		
		def id
      get_id
    end
  
    def category
      "Cases"
    end

    def category2
      if parse_json("Petition Type")
        petition_types = parse_json("Petition Type").map{ |type| type.split(": ")[0].capitalize }.uniq
      end
    end
  
    def category3
      parse_json("Petition Type")
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
  
    def type
      parse_json("Source Material(s)")
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
      parse_json("Tags")
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
          # entries are in form [name](id)|role|(case)[id]
          data = person_info.split("|")
          name_and_id = data[0]
          role = data[1]
          case_and_id = data[2]
          #get names and id's out of brackets, quotes, and parentheses
          # below are markdown fields [name](id)
          person_name = parse_md_brackets(name_and_id)
          person_id = parse_md_parentheses(name_and_id)
          case_name = parse_md_brackets(case_and_id)
          case_id = parse_md_parentheses(case_and_id)
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
      parse_json("Repository")
    end
  
    # def rights_uri
      # TODO
    # end
  
    def source
      @row["Case Citation(s)"]
    end
  
    def title
      @row["Petition or Case Title"]
    end

		def spatial
      places = []
      # all entries are in markdown format: location_name(location_id)
      if parse_json("Repository")
        repositories = parse_json("Repository")
        repositories.each do |repository|
	        place = { "name" => parse_md_brackets(repository), "id" => parse_md_parentheses(repository), "type" => "repository" }
          places << place
        end
      end
      if parse_json("Site(s) of Significance")
        sites = parse_json("Site(s) of Significance")
        sites.each do |site|
          place = { "name" => parse_md_brackets(site), "id" => parse_md_parentheses(site), "type" => "site_of_significance" }
          places << place
        end
      end
      if parse_json("Court Name(s)")
        courts = parse_json("Court Name(s)")
        courts.each do |court|
          place = { "name" => parse_md_brackets(court), "id" => parse_md_parentheses(court), "type" => "court_location"}
          places << place
        end
      end
			places
		end

    def extent
      @row["Length of Case File"]
    end

    def text
      built_text = []
      @row.each do |column_name, value|
        built_text << value.to_s.gsub("\"", "")
      end
      return array_to_string(built_text, " ")
    end

    def event
      events = []
      if @row["Point(s) of Law Cited"]
        points = @row["Point(s) of Law Cited"].split("; ").map { |point| point.strip }
        points.each do |point|
          point_of_law = { "factor" => point, "type" => "points_of_law_cited"}
          events << point_of_law
        end
      end
      if parse_json("Fate of Bound Party(s)")
        fates = parse_json("Fate of Bound Party(s)")
        fates.each do |fate|
          fate_of_party = { "product" => fate, "type" => "fate_of_bound_partys" }
          events << fate_of_party
        end
      end
      if parse_json("Petition Outcome")
        outcomes = parse_json("Petition Outcome")
        outcomes.each do |o|
          outcome = { "product" => o, "type" => "outcome" }
          events << outcome
        end
      end
      events
    end

    def has_source
      sources = []
      if parse_json("Source Material(s)")
        materials = parse_json("Source Material(s)")
        materials.each do |m|
          source = { "title" => m, "role" => "source_materials" }
          sources << source
        end
      end
      sources
    end

    private

    def parse_json(key)
      # given a string, check for the matching field, parse JSON, and remove nil values
      # will return nil is key is missing, or the field has an error value or is otherwise valid JSON
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
      # accepts an array of values in the format person_name(id)|desired_value|case_name(id)
      # make sure there is actual data in the array and not just nil, before looking for the match
      if markdown_array && (markdown_array.select{ |data| data && data.include?(case_id) }.length > 0)
        # find field value (i.e. age) that matches the given case id. look only in the markdown corresponding to the case
        # if there are multiple, return both joined by comma
        markdown_array.select{ |data| data && data.split("|").length == 3 && data.split("|")[2].include?(case_id)}.map{ |kase| kase.split("|")[1] }.uniq.join(", ")
      end
    end

  end
  