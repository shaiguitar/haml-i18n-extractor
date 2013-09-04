module Haml
  module I18n
    class Extractor
      module Helpers

        module StringHelpers
          def html_comment?(txt)
            txt.match(/<!--/) || txt.match(/-->\s*$/)
          end
          def link_to?(txt)
            txt.match(/link_to/) || txt.match(/^\s*['"]/) # %element= 'foo'
          end

          def could_match_script?(txt)
            # want to match:
            # = 'foo'
            # = "foo"
            # = link_to 'bla'
            #
            # but not match:
            # = ruby_var = 2
            scanner = StringScanner.new(txt)
            scanner.scan(/\s+/)
            scanner.scan(/['"]/) || scanner.scan(/link_to/)
          end
        end

        module Highline
          def highlight(str, color = :yellow)
            "<%= color('#{str.to_s}', :black, :on_#{color}) %>"
          end
        end
      end
    end
  end
end

