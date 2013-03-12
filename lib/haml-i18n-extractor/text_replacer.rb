module Haml
  module I18n
    class Extractor
      class TextReplacer

        attr_reader :full_line, :text_to_replace

        T_REGEX = /t\('\..*'\)/
        # limit the number of chars
        LIMIT_KEY_NAME = 30
        # do not pollute the key space it will make it invalid yaml
        NOT_ALLOWED_IN_KEYNAME =  %w( ~ ` ! @ # $ % ^ & * - ( ) , )
        
        def initialize(full_line, text_to_replace)
          @full_line = full_line
          @text_to_replace = text_to_replace
        end

        def replace_hash
          { :replace_with => modified_line }
        end
        
        def modified_line
          full_line = @full_line.dup
          return @full_line if has_been_translated?(full_line)
          remove_surrounding_quotes(full_line)
          full_line
        end
        
        private
        
        def keyname
          "t('.#{to_keyname(@text_to_replace.dup)}')"
        end

        def has_been_translated?(str)
          str.match T_REGEX
        end

        def remove_surrounding_quotes(str)
          # if there are quotes surrounding the string, we want them removed as well...
          unless str.gsub!('"' + @text_to_replace + '"', keyname)
            unless str.gsub!("'" + @text_to_replace + "'", keyname)
              str.gsub!(@text_to_replace, keyname)
            end
          end
        end
        
        def to_keyname(str)
          NOT_ALLOWED_IN_KEYNAME.each{ |rm_me| str.gsub!(rm_me, "") }
          str = str.gsub(/\s+/, " ").strip
          str.downcase.tr(' ', '_')[0..LIMIT_KEY_NAME-1]
        end
        
      end
    end
  end
end