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
        
      end
    end
  end
end