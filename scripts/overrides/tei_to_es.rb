class TeiToEs

  ################
  #    XPATHS    #
  ################

  # in the below example, the xpath for "person" is altered
  def override_xpaths
    xpaths = {}
    xpaths["person"] = "/TEI/teiHeader/profileDesc/particDesc/listPerson/person"
    xpaths["rights"] = "/TEI/teiHeader/fileDesc/publicationStmt/availability/licence"
    xpaths["contributors"] = [
      "/TEI/teiHeader/fileDesc/titleStmt/principal",
      "/TEI/teiHeader/fileDesc/titleStmt/respStmt/name"
    ]
    return xpaths
  end

  #################
  #    GENERAL    #
  #################


  # do something before pulling fields
  def preprocessing
    # read additional files, alter the @xml, add data structures, etc
  end

  # do something after pulling the fields
  def postprocessing
    # change the resulting @json object here
  end

  # Add more fields
  #  make sure they follow the custom field naming conventions
  #  *_d, *_i, *_k, *_t
  def assemble_collection_specific
  #   @json["fieldname_k"] = some_value_or_method
  end

  ################
  #    FIELDS    #
  ################

  # Overrides of default behavior
  # Please see docs/tei_to_es.rb for complete instructions and examples

  # TODO contributor
  # do we want to note that Dr. Jagodinsky is the PI as role?
  def category
    "Documents"
  end
  # def creator
  #   # TODO
  # end

  def source
    caseid = @id[/hc.case.[a-z]{2}.\d{4}/]
    caseid
  end

  def language
    # TODO verify that none of these are primarily english
    "en"
  end

  def languages
    # TODO verify that none of these are multiple languages
    [ "en" ]
  end

  def person
    eles = @xml.xpath(@xpaths["person"])
    people = eles.map do |p|
      {
        "id" => "",
        "name" => get_text("persName", xml: p),
        "role" => get_text("@role", xml: p)
      }
    end
    return people
  end

  # TODO rights_uri, and rights_holder?

  def rights
    get_text(@xpaths["rights"])
  end

  def rights_holder
    # TODO
  end

  def uri
    # TODO
  end

  # TODO text is going to have to be filtered by language field

end
