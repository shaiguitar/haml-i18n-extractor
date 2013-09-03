require 'haml'
require 'haml/parser'
module Haml
  module I18n
    class Extractor
      class TextFinder

        def initialize(orig_line,line_metadata)
          @orig_line = orig_line
          @metadata = line_metadata
        end

        def find
          text_match = process_by_regex.last
        end

        # returns [ line_type, text_found ]
        def process_by_regex
          if Haml::I18n::Extractor.debug?
            binding.pry
            puts '!!!'
            puts @metadata && @metadata[:type]
            puts @orig_line
          end

          #return [:plain, ""] if @metadata.nil? # a linebreak in a haml file, empty.
          @metadata && send("#{@metadata[:type]}", @metadata)
        end

        private

        def plain(line)
          txt = line[:value][:text]
          [:plain, txt]
        end

        def tag(line)
          txt = line[:value][:value]
          if txt
            has_script_in_tag = line[:value][:parse] # %element= foo
            has_exception = txt.match(/link_to/) || txt.match(/^\s*['"]/) # %element= 'foo'
            if has_script_in_tag && !has_exception
              [:tag, ""]
            else
              [:tag, ExceptionFinder.new(txt).find]
            end
          else
            [:tag, ""]
          end
        end

        def script(line)
          txt = line[:value][:text]
          scanner = StringScanner.new(txt)
          scanner.scan(/\s+/)
          if scanner.scan(/['"]/) || scanner.scan(/link_to/)
            [:script, ExceptionFinder.new(txt).find]
          else
            [:script, ""]
          end
        end

        def filter(line)
          #$stderr.puts('=' * 80)
          #$stderr.puts(line.inspect)
          #$stderr.puts("have not handled filters!")
          #$stderr.puts("please remind me to fix this")
          #$stderr.puts('=' * 80)
        end

        # move to method missing and LINE_TYPES_IGNORE?
        # LINE_TYPES_IGNORE = [:silent_script, :haml_comment, :comment, :doctype, :root]
        def silent_script(line); end
        def haml_comment(line); end
        def comment(line); end
        def doctype(line); end
        def root(line); end

      end
    end
  end
end
