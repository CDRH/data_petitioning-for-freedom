require "byebug"
require "open-uri"
class FileCsv < FileType

    def initialize(file_location, options)
        super(file_location, options)
        @csv = read_csv(file_location, options["csv_encoding"])
      end


    def transform_es(old_case_docs, new_case_docs)
        # Calling `super` here uses Datura's FileType.transform_es rather
        # than its FileCsv.transform_es, so copying latter's code for now
        puts "transforming #{self.filename}"
        es_doc = []
        table = table_type
        @csv.each do |row|
            if !row.header_row? && (row["Case ID"] || row["unique_id"])
              new_row = row_to_es(@csv.headers, row, table, old_case_docs)
              es_doc << new_row
            end
        end
        if @options["output"]
            filepath = "#{@out_es}/#{self.filename(false)}.json"
            File.open(filepath, "w") { |f| f.write(pretty_json(es_doc)) }
        end
        es_doc
    end

    def read_csv(file_location, encoding="utf-8")
        CSV.read(file_location, **{
          encoding: encoding,
          headers: true
        })
    end

    def row_to_es(headers, row, table, case_docs)
      # process the cases and people tables with different overrides
      if table == "cases"
        puts "processing " + row["Case ID"]
        new_row = CsvToEs.new(row, options, @csv, self.filename(false)).json
        # add document ids here, since it is difficult to pass data to the override
        new_row["document_ids_k"] = case_docs[new_row["identifier"]]
        new_row
      elsif table == "people"
        puts "processing " + row["unique_id"]
        CsvToEsPerson.new(row, options, @csv, self.filename(false)).json
      end
    end

    def table_type
        if self.filename.include? "people"
            "people"
        else
            "cases"
        end
    end

end
