module Haml
  module I18n
    class Extractor
      class HamlWriter

        attr_accessor :path, :lines, :body

        def initialize(orig_path)
          @path = orig_path.gsub(/.haml$/, ".i18n-extractor.haml")
        end

        def write_file
          f = File.open(@path, "w+")
          f.puts(self.body)
          f.close
        end

      end
    end
  end
end