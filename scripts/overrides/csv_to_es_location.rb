class CsvToEsLocation < CsvToEs

  def id
    get_id
  end

  def get_id
    id = @row["ID"] ? @row["ID"] : "blank"
    id = id.split(" ")[0]
    id
  end

  def title
    @row["primary field"]
  end

  def person
  end

  def rdf
  end

  def category
    "Locations"
  end

end
