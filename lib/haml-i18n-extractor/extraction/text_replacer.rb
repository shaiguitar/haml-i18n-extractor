module Haml
  module I18n
    class Extractor
      class TextReplacer

        attr_reader :full_line, :text_to_replace, :line_type

        T_REGEX = /t\('\..*'\)/
        # limit the number of chars
        LIMIT_KEY_NAME = 30
        # do not pollute the key space it will make it invalid yaml
        NOT_ALLOWED_IN_KEYNAME =  %w( ~ ` ! @ # $ % ^ & * - ( ) , ? { } = ' " : )

        def initialize(full_line, text_to_replace,line_type, metadata = {})
          @orig_line = @full_line = full_line
          @text_to_replace = text_to_replace
          @metadata = metadata
          if LINE_TYPES_ALL.include?(line_type)
            @line_type = line_type
          else
            raise Extractor::NotDefinedLineType, "line type #{line_type} for #{full_line} does not make sense!"
          end
        end

        def replace_hash
          @replace_hash ||= { :modified_line => modified_line, :keyname => keyname, :replaced_text => @text_to_replace }
        end

        # the new full line, including a `t()` replacement instead of the `text_to_replace` portion.
        def modified_line
          full_line = @full_line.dup
          return @full_line if has_been_translated?(full_line)
          remove_surrounding_quotes(full_line)
          apply_ruby_evaling(full_line)
          full_line
        end

        private

        def keyname
          text_to_replace = @text_to_replace.dup
          if has_been_translated?(text_to_replace)
            text_to_replace
          else
            name = to_keyname(text_to_replace)
            name = to_keyname(@orig_line.dup) if name.empty?
            "t('.#{name}')"
          end
        end

        # adds the = to the right place in the string ... = t() stuff.
        def apply_ruby_evaling(str)
          if LINE_TYPES_ADD_EVAL.include?(@line_type)
            if @line_type == :tag
              str.match /^([^\s\t]*)(.*)$/
              elem, keyname = $1, $2
              str.gsub!($2, "= #{$2.strip}") unless already_evaled?(elem)
            elsif @line_type == :plain
              str.gsub!(str, "= "+str)
            end
          end
        end

        def already_evaled?(elem)
          # poor elem.split('').last == '='
          # better, haml guts:
          @metadata[:value] && @metadata[:value][:parse]
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
