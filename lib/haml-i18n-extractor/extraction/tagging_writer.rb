module Haml
  module I18n
    class Extractor
      class TaggingWriter

        DB = ".tags.haml-i18n-extractor"
        def initialize
          @file = File.open(DB, "a+")
        end

        def write(path, lineno)
          tag = "#{path}:#{lineno}\n"
          @file.write(tag)
          @file.flush
        end

      end
    end
  end
end

