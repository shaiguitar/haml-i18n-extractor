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

        # returns [ line_type, text_found ]
        def process_by_regex
          if Haml::I18n::Extractor.debug?
            binding.pry
            puts '!!!'
            puts @metadata && @metadata[:type]
            puts @orig_line
          end
          # if any of the handler methods return nil the extractor just outputs orig_line and keeps on going.
          # if there's an empty string that should do the trick to ( ExceptionFinder can return no match that way )
          @metadata && send("#{@metadata[:type]}", @metadata)
        end

        private

        #FIXME move all these matches into a helper of some sort.

        def plain(line)
          txt = line[:value][:text]
          return nil if txt.match(/<!--/) || txt.match(/-->\s*$/) # ignore html comments
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

        # returns nil, so extractor just keeps the orig_line and keeps on going.
        #
        # move to method missing and LINE_TYPES_IGNORE?
        # LINE_TYPES_IGNORE = [:silent_script, :haml_comment, :comment, :doctype, :root]
        def filter(line); end
        def silent_script(line); end
        def haml_comment(line); end
        def comment(line); end
        def doctype(line); end
        def root(line); end

      end
    end
  end
end
