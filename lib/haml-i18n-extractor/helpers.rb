module Haml
  module I18n
    class Extractor
      module Helpers

        module StringHelpers

          # limit the number of chars
          LIMIT_KEY_NAME = 60

          # do not pollute the key space it will make it invalid yaml
          NOT_ALLOWED_IN_KEYNAME =  %w( ~ ` ! @ # $ % ^ & * - ( ) , ? { } = ' ’ " : ; \\ / . | > < [ ] )

          def interpolated?(str)
            str.match(/\#{/)
          end

          def normalized_name(str)
            NOT_ALLOWED_IN_KEYNAME.each{ |rm_me| str.gsub!(rm_me, '') }
            str = str.gsub(/\s+/, ' ').strip.downcase
            str.tr(' ', '_')[0..LIMIT_KEY_NAME]
          end

          def normalize_interpolation(str)
            ret = change_one_interpolation(str)
            if ret && interpolated?(ret)
              ret = normalize_interpolation(ret)
            end
            ret
          end

          def change_one_interpolation(str)
            if interpolated?(str)
              scanner = StringScanner.new(str)
              scanner.scan_until(/\#{(.*?)}/)
              ret = "#{scanner.pre_match}"
              ret << "%{#{normalized_name(scanner.matched)}}"
              ret << "#{scanner.post_match}"
            else
              ret = str
            end
            ret
          end

          def html_comment?(txt)
            txt.match(/<!--/) || txt.match(/-->\s*$/)
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
