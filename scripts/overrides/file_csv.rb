require "byebug"
require "open-uri"
class FileCsv < FileType

    def initialize(file_location, options)
        super(file_location, options)
        #read the spreadsheet from external source
        spreadsheet = open('https://docs.google.com/spreadsheets/d/1sL3fKAt4mKcRnTtOpnFbOyD3Sbk-fAg6-iklfRP_qQY/export?format=csv&id=1sL3fKAt4mKcRnTtOpnFbOyD3Sbk-fAg6-iklfRP_qQY&gid=1728505676')
        IO.copy_stream(spreadsheet, file_location)
        byebug
        #pick out the sheet I want
        #save it to source/csv as habeas.csv (or whatever, maybe we need multiple files)
        @csv = read_csv(file_location, options["csv_encoding"])
      end


    def transform_es
        # Calling `super` here uses Datura's FileType.transform_es rather
        # than its FileCsv.transform_es, so copying latter's code for now
        byebug
        puts "transforming #{self.filename}"
        es_doc = []
        @csv.each do |row|
            if !row.header_row?
                es_doc << row_to_es(@csv.headers, row)
            end
            end
            
        if @options["output"]
            filepath = "#{@out_es}/#{self.filename(false)}.json"
            File.open(filepath, "w") { |f| f.write(pretty_json(es_doc)) }
        end
        es_doc
    end

end