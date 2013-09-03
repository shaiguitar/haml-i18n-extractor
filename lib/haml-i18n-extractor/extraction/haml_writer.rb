module Haml
  module I18n
    class Extractor
      class HamlWriter

        attr_accessor :path, :lines, :body, :type

        def initialize(orig_path, options = {})
          @type = options[:type] || :dump # safe default.

          if overwrite?
            @path = orig_path
          elsif dump?
            @path = orig_path.gsub(/.haml$/, ".i18n-extractor.haml")
          end

        end

        def write_file
          f = File.open(@path, "w+")
          f.puts(self.body)
          f.close
        end

        def overwrite?
          @type == :overwrite
        end
        
        def dump?
          @type == :dump
        end
        
      end
    end
  end
end
