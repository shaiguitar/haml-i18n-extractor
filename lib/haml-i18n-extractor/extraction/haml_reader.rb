module Haml
  module I18n
    class Extractor
      class HamlReader

        attr_reader :body, :path, :lines

        def initialize(path)
          file = File.open(path, "r")
          @path = path
          @body = file.read
          file.rewind
          @lines = file.readlines
          file.rewind
        end

        # cache me?
        def metadata
          parser = Haml::I18n::Extractor::HamlParser.new(@body)
          line_metadatas = parser.flattened_values
          metadata = {}
          # blank lines are missing! so api [] access per line in file, not by array index.
          line_metadatas.each{|line_data| metadata.merge!(line_data[:line] => line_data) }
          metadata
        end

      end
    end
  end
end
