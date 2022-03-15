require "byebug"
require "open-uri"
class FileCsv < FileType

    def initialize(file_location, options)
        super(file_location, options)
        #read the spreadsheet from external source
        key = "1UjklbuQwN3uyEbi2wzoOJunC4a-h58RJ2hxa2whFxWI"
        # sheets = {
        #     "iowa.csv" => "18278945",
        #     "kansas.csv" => "1493529418",
        #     "missouri.csv" => "161023288",
        #     "nebraska.csv" => "0",
        #     "us.csv" => "1342876964",
        #     "washington.csv" => "1217279103"
        # }
        name = file_location.split("/")[-1]
        gid = "161023288"
        url = "https://docs.google.com/spreadsheets/d/#{key}/export?format=csv&id=#{key}&gid=#{gid}"
        spreadsheet = open(url)
        IO.copy_stream(spreadsheet, file_location)
        
        #pick out the sheet I want
        #save it to source/csv as habeas.csv (or whatever, maybe we need multiple files)
        @csv = read_csv(file_location, options["csv_encoding"])
      end


    def transform_es
        # Calling `super` here uses Datura's FileType.transform_es rather
        # than its FileCsv.transform_es, so copying latter's code for now
        puts "transforming #{self.filename}"
        es_doc = []
        @csv.each do |row|
            if !row.header_row? && row["Case ID"] && row["Case ID"].start_with?("hc")
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
