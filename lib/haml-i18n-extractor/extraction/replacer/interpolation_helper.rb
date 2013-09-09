module Haml
  module I18n
    class Extractor
      class InterpolationHelper

        include Helpers::StringHelpers

        # takes an original_line and text_to_replace, keyname_name and gives back the result for that...
        def initialize(text_to_replace, t_name)
          if Extractor.debug?
            puts "<interpolationhelper>#{text_to_replace.inspect} #{t_name.inspect}</interpolationhelper>"
          end
          @t_name = t_name
          @text_to_replace = text_to_replace
        end

        def keyname_with_vars()
          "t('.#{@t_name}', #{interpolated_vars})"
        end

        def interpolated_vars
          interpolations.map{|v|
            ":#{normalized_name(v.dup)} => (#{v})"
          }.join(", ")
        end

        # matches multiple
        def interpolations(arr = [], str = @text_to_replace)
          # recurse scanner until no interpolations or string left
          return arr if str.nil? || str.empty? || !interpolated?(str)
          scanner = StringScanner.new(str)
          scanner.scan_until(/\#{.*?}/)
          so_far = scanner.pre_match + scanner.matched
          arr << extract_interpolation(so_far)
          arr = interpolations(arr, scanner.rest)
        end

        def extract_interpolation(str)
          scanner = StringScanner.new(str)
          scanner.scan_until /\#{/
          rest_scanner = StringScanner.new(scanner.rest)
          rest_scanner.scan_until(/}/)
          interpolated = rest_scanner.pre_match
        end


      end
    end
  end
end

