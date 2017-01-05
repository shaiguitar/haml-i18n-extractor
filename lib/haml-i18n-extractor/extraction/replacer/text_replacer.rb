module Haml
  module I18n
    class Extractor
      class TextReplacer
        include Helpers::StringHelpers

        TAG_REGEX = /%\w+/
        TAG_CLASSES_AND_ID_REGEX = /(?:[.#]\w+)*/
        TAG_ATTRIBUTES_REGEX = /(?:\{[^}]+\})?/

        attr_reader :full_line, :text_to_replace, :line_type

        def initialize(full_line, text_to_replace, line_type, path, metadata = {}, options = {})
          @path = path
          @orig_line = @full_line = full_line
          @text_to_replace = text_to_replace
          @metadata = metadata
          @options = options
          if LINE_TYPES_ALL.include?(line_type)
            @line_type = line_type
          else
            raise Extractor::NotDefinedLineType, "line type #{line_type} for #{full_line} does not make sense!"
          end
        end

        def result
          @result ||= build_result
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
          return @full_line if has_been_translated?(@full_line) && !@options[:add_filename_prefix]
          full_line = @full_line.dup
          keyname = orig_interpolated? ? interpolation_helper.keyname_with_vars : t_method
          gsub_replacement!(full_line, @text_to_replace, keyname)
          apply_ruby_evaling!(full_line, keyname)
          full_line
        end

        private

        def build_result
          result_class = Haml::I18n::Extractor::ReplacerResult
          expression = @line_type == :script || tag_with_code? ? @text_to_replace[1...-1] : @text_to_replace
          if expression.strip.match(/^#\{[^}]+\}$/)
            result_class.new(nil, nil, @text_to_replace, false, @path)
          else
            result_class.new(modified_line, t_name, @text_to_replace, true, @path)
          end
        end

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

          if (@options[:add_filename_prefix])
            name = @path.gsub(@options[:base_path], '').gsub(/(\.html)?\.haml/, '').gsub(/\//, '.').gsub('_', '') + '.' + name
          end
          name
        end

        # t('.the_key_to_use')
        def t_method
          with_translate_method(t_name)
        end

        def with_translate_method(name)
          prefix = @options[:add_filename_prefix] ? '' : '.'
          "t('#{prefix}#{name}')"
        end

        # adds the = to the right place in the string ... = t()
        def apply_ruby_evaling!(str, keyname)
          if LINE_TYPES_ADD_EVAL.include?(@line_type)
            if @line_type == :tag
              scanner = StringScanner.new(str.dup)
              scanner.skip(TAG_REGEX)
              scanner.skip(TAG_CLASSES_AND_ID_REGEX)
              scanner.skip(TAG_ATTRIBUTES_REGEX)
              if scanner.scan_until(/[\s]*#{Regexp.escape(keyname)}/)
                unless already_evaled?(scanner.pre_match)
                  str[0..-1] = "#{scanner.pre_match}=#{scanner.matched}#{scanner.post_match}"
                end
              end
            elsif @line_type == :plain || (@line_type == :script && !already_evaled?(full_line))
              str.gsub!(str, "= "+str)
            end
          end
        end

        def tag_with_code?
          @metadata[:value] && @metadata[:value][:parse]
        end

        def already_evaled?(str)
          if @line_type == :tag
            if orig_interpolated?
              # for tags that come in interpolated we need to explicitly
              # check that they aren't evaled alreay, the metadata lies
              #   %tag foo #{var} bar
              str.split('').last == '='
            else
              tag_with_code?
            end
          elsif @line_type == :script
            # we need this for tags that come in like :plain but have interpolation
            str.match(/^[\s]*=/)
          end
        end

        def has_been_translated?(str)
          str.match T_REGEX
        end

        def gsub_replacement!(str, text_to_replace, keyname_method)
          # FIXME refactor this method
          text_to_replace = $1 if (orig_interpolated? && text_to_replace.match(/^['"](.*)['"]$/))
          scanner = StringScanner.new(str.dup)
          str[0..-1] = ''
          if line_type == :tag
            if @options[:place] == :content
              scanner.skip(TAG_REGEX)
              scanner.skip(TAG_CLASSES_AND_ID_REGEX)
              scanner.skip(TAG_ATTRIBUTES_REGEX)
            elsif @options[:place] == :attribute
              scanner.skip(TAG_REGEX)
              scanner.skip(TAG_CLASSES_AND_ID_REGEX)
              scanner.skip_until(/\b#{@options[:attribute_name]}:|:#{@options[:attribute_name]}\s*=>\s*/)
            end
          end
          scanner.scan_until(/(['"]|)#{Regexp.escape(text_to_replace)}\1/)
          str << scanner.pre_match << keyname_method << scanner.post_match
        end

      end
    end
  end
end
