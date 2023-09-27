class WebsToEs < XmlToEs

  def override_xpaths
    {
      "text" => "//div",
      "title" => "//h1[1]"
    }
  end

  def assemble_collection_specific
  #   @json["fieldname_k"] = some_value_or_method
  end

  def date(before=true)
    Datura::Helpers.date_standardize("2021", before)
  end

  def date_display
    "2021"
  end

  def language
    "en"
  end

  def category
    "Site Section"
  end

  def subcategory
    "Site Section"
  end

  def title
    get_text(@xpaths["title"])
  end

  def uri
    # the ids are structured like the url
    # about_people -> about/people
    # so long as all of the webscraped paths are only
    # nested one deep, the below should work
    # otherwise we need to revisit this and subcategory
    subcat, underscore, final_url_piece = @id.partition("_")
    File.join(@options["site_url"], subcat, final_url_piece)
  end

  def uri_data
    uri
  end

  def uri_html
    uri
  end

end
