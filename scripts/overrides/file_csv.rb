require "byebug"
class FileCsv < FileType

    def transform_es
        # Calling `super` here uses Datura's FileType.transform_es rather
        # than its FileCsv.transform_es, so copying latter's code for now
        puts "transforming #{self.filename}"
        es_doc = []
        @csv.each do |row|
            byebug
            begin
                if !row.header_row?
                    es_doc << row_to_es(@csv.headers, row)
                end
            rescue
                puts "nil error"
            end
        end
        if @options["output"]
            filepath = "#{@out_es}/#{self.filename(false)}.json"
            File.open(filepath, "w") { |f| f.write(pretty_json(es_doc)) }
        end
        es_doc
    end

end