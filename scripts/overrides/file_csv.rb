require "byebug"
require "open-uri"
class FileCsv < FileType

    def initialize(file_location, options)
        super(file_location, options)
        @csv = read_csv(file_location, options["csv_encoding"])
      end


    def transform_es
        # Calling `super` here uses Datura's FileType.transform_es rather
        # than its FileCsv.transform_es, so copying latter's code for now
        puts "transforming #{self.filename}"
        es_doc = []
        @csv.each do |row|
            if !row.header_row? && row["Case ID"]
                es_doc << row_to_es(@csv.headers, row)
            end
        end
        if @options["output"]
            filepath = "#{@out_es}/#{self.filename(false)}.json"
            File.open(filepath, "w") { |f| f.write(pretty_json(es_doc)) }
        end
        es_doc
    end

    def read_csv(file_location, encoding="utf-8")
        CSV.read(file_location, {
          encoding: encoding,
          headers: true
        })
    end

end
