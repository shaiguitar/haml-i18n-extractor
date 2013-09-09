module Haml
  module I18n
    class Extractor
      class TextReplacer

        include Helpers::StringHelpers

        attr_reader :full_line, :text_to_replace, :line_type


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

        def result
          @result ||= Haml::I18n::Extractor::ReplacerResult.new(modified_line, t_name, @text_to_replace, true, @path)
        end

        def replace_hash
          #legacy
          result.info
        end

        def interpolation_helper
          Haml::I18n::Extractor::InterpolationHelper.new(@text_to_replace, t_name)
        end

        def orig_interpolated?
          interpolated?(@orig_line)
        end

        # the new full line, including a `t()` replacement instead of the `text_to_replace` portion.
        def modified_line
          return @full_line if has_been_translated?(@full_line)
          full_line = @full_line.dup
          #puts t_method.inspect if Haml::I18n::Extractor.debug?
          keyname = orig_interpolated? ? interpolation_helper.keyname_with_vars : t_method
          gsub_replacement!(full_line, @text_to_replace, keyname)
          apply_ruby_evaling!(full_line, keyname)
          full_line
        end
 
        private

        T_REGEX = /t\('\.(.*?)'\)/

        # the_key_to_use ( for example in t('.the_key_to_use')
        def t_name(to_replace = @text_to_replace, orig_line = @orig_line)
          text_to_replace = to_replace.dup
          if has_been_translated?(text_to_replace)
            text_to_replace.match T_REGEX
            name = normalized_name($1.dup)
          else
            name = normalized_name(text_to_replace.dup)
            name = normalized_name(orig_line.dup) if name.empty?
          end
          name
        end

        # t('.the_key_to_use')
        def t_method
          with_translate_method(t_name)
        end

        def with_translate_method(name)
          "t('.#{name}')"
        end

        # adds the = to the right place in the string ... = t()
        def apply_ruby_evaling!(str, keyname)
          if LINE_TYPES_ADD_EVAL.include?(@line_type)
            if @line_type == :tag
              match_keyname = Regexp.new('[\s\t]*' + Regexp.escape(keyname))
              str.match(/(.*?)(#{match_keyname})/)
              elem = $1
              if elem
                str.gsub!(Regexp.new(Regexp.escape(elem)), "#{elem}=") unless already_evaled?(elem)
              end
            elsif @line_type == :plain || (@line_type == :script && !already_evaled?(full_line))
              str.gsub!(str, "= "+str)
            end
          end
        end

        def already_evaled?(str)
          if @line_type == :tag
            if orig_interpolated?
              # for tags that come in interpolated we need to explicitly
              # check that they aren't evaled alreay, the metadata lies
              #   %tag foo #{var} bar
              str.split('').last == '='
            else
              @metadata[:value] && @metadata[:value][:parse]
            end
          elsif @line_type == :script
            # we need this for tags that come in like :plain but have interpolation
            str.match(/^[\s\t]*=/)
          end
        end

        def has_been_translated?(str)
          str.match T_REGEX
        end

        def gsub_replacement!(str, text_to_replace, keyname_method)
          # FIXME refactor this method
         text_to_replace = $1 if (orig_interpolated? && text_to_replace.match(/^['"](.*)['"]$/))

          # if there are quotes surrounding the string, we want them removed as well...
          unless str.gsub!('"' + text_to_replace + '"', keyname_method )
            unless str.gsub!("'" + text_to_replace + "'", keyname_method)
              str.gsub!(text_to_replace, keyname_method)
            end
          end
        end

      end
    end
  end
end
