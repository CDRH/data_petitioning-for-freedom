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

  def category2
    @row["location type"]
  end

  def category3
    parse_json("location subtype")
  end

  def spatial
    lat = @row["latitude"].to_f
    lon = @row["longitude"].to_f
    # note that coordinates is a geo_point field and elasticsearch requires [lon, lat] format.
    {
      "role" => "location",
      "name" => @row["locality_built"],
      "coordinates" => [lon, lat],
      "state" => @row["state"],
      "county" => @row["county"],
      "city" => @row["locality"],
      "trait1" => @row["coordinate specificity"]
    }
  end

end
