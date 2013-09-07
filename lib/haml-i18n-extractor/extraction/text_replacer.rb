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

        def initialize(full_line, text_to_replace,line_type, path, metadata = {})
          @path = path
          @orig_line = @full_line = full_line
          @text_to_replace = text_to_replace
          @metadata = metadata
          if LINE_TYPES_ALL.include?(line_type)
            @line_type = line_type
          else
            raise Extractor::NotDefinedLineType, "line type #{line_type} for #{full_line} does not make sense!"
          end
        end

        class ReplacerResult
          attr_accessor :modified_line, :keyname, :replaced_text, :should_be_replaced, :path

          def initialize(modified_line, keyname, replaced_text, should_be_replaced, path)
            @modified_line = modified_line
            @keyname = keyname
            @replaced_text = replaced_text
            @should_be_replaced = should_be_replaced
            @path = path
          end

          def info
            { :modified_line => @modified_line, :keyname => @keyname, :replaced_text => @replaced_text, :path => @path}
          end
        end

        def result
          t_name = keyname(@text_to_replace, @orig_line)
          @result ||= ReplacerResult.new(modified_line, t_name, @text_to_replace, true, @path)
        end

        def replace_hash
          result.info
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

        def keyname(to_replace, orig_line)
          text_to_replace = to_replace.dup
          if has_been_translated?(text_to_replace)
            text_to_replace
          else
            name = normalize_name(text_to_replace)
            name = normalize_name(orig_line.dup) if name.empty?
            with_translate_method(name)
          end
        end

        def with_translate_method(name)
          "t('.#{name}')"
        end

        # adds the = to the right place in the string ... = t()
        def apply_ruby_evaling(str)
          if LINE_TYPES_ADD_EVAL.include?(@line_type)
            if @line_type == :tag
              t_name = keyname(@text_to_replace, @orig_line)
              match_keyname = Regexp.new('[\s\t]*' + Regexp.escape(t_name))
              str.match(/(.*?)(#{match_keyname})/)
              elem = $1
              if elem
                str.gsub!(Regexp.new(Regexp.escape(elem)), "#{elem}=") unless already_evaled?(elem)
              end
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
          t_name = keyname(@text_to_replace, @orig_line)
          unless str.gsub!('"' + @text_to_replace + '"', t_name )
            unless str.gsub!("'" + @text_to_replace + "'", t_name)
              str.gsub!(@text_to_replace, t_name)
            end
          end
        end

        def normalize_name(str)
          NOT_ALLOWED_IN_KEYNAME.each{ |rm_me| str.gsub!(rm_me, "") }
          str = str.gsub(/\s+/, " ").strip
          str.downcase.tr(' ', '_')[0..LIMIT_KEY_NAME-1]
        end

      end
    end
  end
end
