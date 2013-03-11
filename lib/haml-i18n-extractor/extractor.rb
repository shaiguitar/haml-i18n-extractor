module Haml
  module I18n
    class Extractor
      
      class InvalidSyntax < StandardError ; end

      attr_reader :haml_reader

      def initialize(haml_path)
        @haml_reader = Haml::I18n::Extractor::HamlReader.new(haml_path)
        validate_haml(@haml_reader.body)
      end

      def run!
        @haml_reader.lines.each { |haml_line|
          line_match = Haml::I18n::Extractor::TextFinder.new(haml_line)
          line_replaced = Haml::I18n::Extractor::TextReplacer.new(haml_line, line_match)
        }
      end

      private
      
      def validate_haml(haml)
        options ||= Haml::Options.new
        parser = Haml::Parser.new(haml, options)
        parser.parse
        rescue Haml::SyntaxError
          raise InvalidSyntax, "invalid syntax for haml #{@haml_reader.path}"
      end
      
    end
  end
end
