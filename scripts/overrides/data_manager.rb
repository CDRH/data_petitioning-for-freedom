require "json"
require "open-uri"
require "uri"

class Datura::DataManager
  def pre_file_preparation
    # inputting and outputting hashes with cases and associated docuemnts
    # there are two hashes because it reads in one that was previously created, 
    # and creates one as it reads in the data, which will be outputted as json

    if @options["scrape_website"]
      scrape_website
    else
      puts %{Files in source/webs are not being refreshed from the website
        contents. If you wish to scrape the petitioning for freedom website, please
        add or update config/public.yml to use "scrape_website: true"}
    end
    @out_json = File.join(@options["collection_dir"], "source", "json")
    filepath = "#{@out_json}/case_documents.json"
    case_json = File.read(filepath)
    @old_case_documents = JSON.parse(case_json)
    @new_case_documents = {}
  end

  def print_error(e)
    puts %{Something went wrong while scraping the website:
  URL(S): #{@url}
  ERROR: #{e}
To post content, please check the endpoint in config/public.yml, or
temporarily disable the scrape_website setting in that file}.red
  end

  def transform_and_post(file)
    # elasticsearch
    if should_transform?("es")
      if @options["transform_only"]
        # For this project, need to send the hashes of cases and documents to transform
        begin
          res_es = file.transform_es(@old_case_documents, @new_case_documents)
        rescue => e
          error_with_transform_and_post("#{e}", @error_es)
        end
      else
        byebug
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

  end

  def post_batch_processing
    #output as json the hash associating cases and documents
    if @new_case_documents && @new_case_documents.length > 2
      case_documents = @new_case_documents.to_json
      filepath = "#{@out_json}/case_documents.json"
      File.open(filepath, "w") { |f| f.write(case_documents) }
    end
  end

  def build_html(urls)
    combined = ""
    # retrieve and then combine into a single file which can be parsed
    urls.each do |url|
      raw = URI.open(url) { |f| f.read }
      # wrap the web scraping results in a div
      combined << "<div>"
      html = Nokogiri::HTML(raw)
      combined << html.at_xpath("//div[@id='content-wrapper']").inner_html
      combined << "</div>"
    end
    combined
  rescue => exception
    print_error(exception, urls)
  end



  

  def scrape_website
    @url = File.join(@options["site_url"], @options["scrape_endpoint"])
    puts "getting list of urls to scrape from #{@url}"
    list_of_pages = URI.open(@url) { |f| f.read }
    JSON.parse(list_of_pages).each do |page|
      site_url_for_regex = @options["site_url"]
        .gsub("/", "\/")
        .gsub(".", "\.")
      id = page
        .first[/^#{site_url_for_regex}\/(.*)/, 1]
        .gsub("/", "_")
      output_file = "#{@options["collection_dir"]}/source/webs/#{id}.html"
      html = build_html(page)
      File.open(output_file, 'w') { |file| file.write(html) }
    end
  end

end
