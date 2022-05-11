class FileType
  def transform_es(old_case_docs, new_case_docs)
    es_req = []
    begin
      file_xml = parse_markup_lang_file
      # check if any xpaths hit before continuing
      results = file_xml.xpath(*subdoc_xpaths.keys)
      if results.length == 0
        raise "No possible xpaths found fo file #{self.filename}, check if XML is valid or customize 'subdoc_xpaths' method"
      end
      subdoc_xpaths.each do |xpath, classname|
        subdocs = file_xml.xpath(xpath)
        subdocs.each do |subdoc|
          file_transformer = classname.new(subdoc, @options, file_xml, self.filename(false))
          if classname == TeiToEs
            # build the associations of cases and documents here
            case_id = file_transformer.source
            document_id = file_transformer.json["identifier"]
            if new_case_docs[case_id]
              new_case_docs[case_id] << document_id
            else
              new_case_docs[case_id] = [document_id]
            end
          end
          es_req << file_transformer.json
        end
      end
      if @options["output"]
        filepath = "#{@out_es}/#{self.filename(false)}.json"
        File.open(filepath, "w") { |f| f.write(pretty_json(es_req)) }
      end
      return es_req
    rescue => e
      puts "something went wrong transforming #{self.filename}"
      raise e
    end
  end
  def post_es(old_case_docs, new_case_docs, url=nil)
    url = url || "#{@options["es_path"]}/#{@options["es_index"]}"
    begin
      transformed = transform_es(old_case_docs, new_case_docs)
    rescue => e
      return { "error" => "Error transforming ES for #{self.filename(false)}: #{e}" }
    end
    if transformed && transformed.length > 0
      transformed.each do |doc|
        id = doc["identifier"]
        puts "posting #{id}"
        puts "PATH: #{url}/_doc/#{id}" if options["verbose"]
        # NOTE: If you need to do partial updates rather than replacement of doc
        # you will need to add _update at the end of this URL
        begin
          RestClient.put("#{url}/_doc/#{id}", doc.to_json, {:content_type => :json } )
        rescue => e
          return { "error" => "Error transforming or posting to ES for #{self.filename(false)}: #{e.response}" }
        end
      end
    else
      return { "error" => "No file was transformed" }
    end
    return { "docs" => transformed }
  end
end
