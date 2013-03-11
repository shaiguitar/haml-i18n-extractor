module Haml
  module I18n
    class Extractor
      class TextReplacer

        # limit the number of chars
        LIMIT_KEY_NAME = 30

        # do not pollute the key space it will make it invalid yaml
        NOT_ALLOWED_IN_KEYNAME =  %w( ~ ` ! @ # $ % ^ & * - ( ) )
        
        def initialize(full_line, text_to_replace)
          @full_line = full_line
          @text_to_replace = text_to_replace
        end

        def replace!
          t_text = "t(.#{to_keyname(@full_line)})"
          replace_with = @full_line.gsub(@full_line, t_text)
          {:replace_with => replace_with, :replace_this => @text_to_replace }
        end

        private
        
        def to_keyname(str)
          NOT_ALLOWED_IN_KEYNAME.each{|rm_me|
            str.gsub!(rm_me, "")
          }
          str = str.gsub(/\s+/, " ").strip
          str.downcase.tr(' ', '_')[0..LIMIT_KEY_NAME-1]
        end
        
      end
    end
  end
end