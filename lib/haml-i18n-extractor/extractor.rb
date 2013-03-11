module Haml
  module I18n
    class Extractor
      
      class InvalidSyntax < StandardError ; end

      def self.debug?
        ENV['DEBUG']
      end

      attr_reader :haml_reader
      attr_reader :haml_writer

      def initialize(haml_path)
        @haml_reader = Haml::I18n::Extractor::HamlReader.new(haml_path)
        validate_haml(@haml_reader.body)
        @haml_writer = Haml::I18n::Extractor::HamlWriter.new(haml_path)
      end

      def new_body
        new_lines = []
        @haml_reader.lines.map do |orig_line|
          orig_line.chomp!
          orig_line.rstrip.match(/([ \t]+)?(.*)/)   # taken from haml lib
          whitespace_indentation = $1               # keep indentation to use later when printing out.
          orig_line = $2                            # but in order to find text it needs no indentiation, we just want the text.
          line_match = Haml::I18n::Extractor::TextFinder.new(orig_line).find
          if line_match && !line_match.empty?
            replacer = Haml::I18n::Extractor::TextReplacer.new(orig_line, line_match)
            modified_line = replacer.replace_hash[:replace_with]
            new_lines << "#{whitespace_indentation}#{modified_line}"
          else
            new_lines << "#{whitespace_indentation}#{orig_line}"
          end
        end
        new_lines.join("\n")
      end
      
      def assign_new_body
        @haml_writer.body = new_body
      end
      
      def run
        assign_new_body
        validate_haml(@haml_writer.body)
        @haml_writer.write_file
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
