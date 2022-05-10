class Datura::DataManager
  def pre_file_preparation
    @out_json = File.join(@options["collection_dir"], "source", "json")
    filepath = "#{@out_json}/case_documents.json"
    case_json = File.read(filepath)
    @old_case_documents = JSON.parse(case_json)
    @new_case_documents = {}
  end
  def transform_and_post(file)
    # elasticsearch
    if should_transform?("es")
      if @options["transform_only"]
        # TODO transformation is not treated the same way here as in
        # most post methods, so having to use try catch block
        begin
          res_es = file.transform_es(@old_case_documents, @new_case_documents)
        rescue => e
          error_with_transform_and_post("#{e}", @error_es)
        end
      else
        res_es = file.post_es(@old_case_documents, @new_case_documents, @es_url)
        if res_es && res_es.has_key?("error")
          error_with_transform_and_post(res_es["error"], @error_es)
        end
      end
    end

    # html
    begin
      res_html = file.transform_html if should_transform?("html")
      if res_html && res_html.has_key?("error")
        error_with_transform_and_post(res_html["error"], @error_html)
      end
    rescue => e
      error_with_transform_and_post("#{e}", @error_html)
    end

    # iiif
    begin
      res_iiif = file.transform_iiif if should_transform?("iiif")
      if res_iiif && res_iiif.has_key?("error")
        error_with_transform_and_post(res_iiif["error"], @error_iiif)
      end
    rescue => e
      error_with_transform_and_post("#{e}", @error_iiif)
    end

    # solr
    if should_transform?("solr")
      if @options["transform_only"]
        res_solr = file.transform_solr
      else
        res_solr = file.post_solr(@solr_url)
      end
      if res_solr && res_solr.has_key?("error")
        error_with_transform_and_post(res_solr["error"], @error_solr)
      end
    end
  end
  def post_batch_processing
    #output as json the hash associating cases and documents
    if @new_case_documents && @new_case_documents.length > 2
      case_documents = @new_case_documents.to_json
      filepath = "#{@out_json}/case_documents.json"
      File.open(filepath, "w") { |f| f.write(case_documents) }
    end
  end
end
