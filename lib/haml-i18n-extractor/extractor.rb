module Haml
  module I18n
    class Extractor

      def self.debug?
        ENV['DEBUG']
      end
      
      class InvalidSyntax < StandardError ; end
      class NothingToTranslate < StandardError ; end
      class NotDefinedLineType < StandardError ; end

      LINE_TYPES_ALL = [:text, :not_text, :loud, :silent, :element]
      LINE_TYPES_ADD_EVAL = [:text, :element]
      
      attr_reader :haml_reader, :haml_writer
      attr_reader :locale_hash, :yaml_tool

      def initialize(haml_path)
        @haml_reader = Haml::I18n::Extractor::HamlReader.new(haml_path)
        validate_haml(@haml_reader.body)
        @haml_writer = Haml::I18n::Extractor::HamlWriter.new(haml_path)
        @yaml_tool = Haml::I18n::Extractor::YamlTool.new
        @locale_hash = {}
      end

      def run
        assign_replacements
        validate_haml(@haml_writer.body)
        @haml_writer.write_file
        @yaml_tool.write_file
      end
      
      def assign_new_body
        @haml_writer.body = new_body
      end
      
      def assign_yaml
        @yaml_tool.locale_hash = @locale_hash
      end
      
      def assign_replacements
        assign_new_body
        assign_yaml
      end

      # processes the haml document, replaces the input body to an output body of replacements. also sets an in memory hash of replacement info
      # to be used later by the yaml tool.
      # keep indentation to use later when printing out.
      def new_body
        new_lines = []
        file_has_been_parsed = false
        @haml_reader.lines.each_with_index do |orig_line, line_no|
          orig_line.chomp!
          orig_line.rstrip.match(/([ \t]+)?(.*)/)
          whitespace_indentation = $1
          orig_line = $2
          line_type, line_match = Haml::I18n::Extractor::TextFinder.new(orig_line).process_by_regex
          if line_match && !line_match.empty?
            file_has_been_parsed = true
            replacer = Haml::I18n::Extractor::TextReplacer.new(orig_line, line_match, line_type)
            @locale_hash[line_no] = replacer.replace_hash.dup.merge!({:path => @haml_reader.path })
            new_lines << "#{whitespace_indentation}#{replacer.replace_hash[:modified_line]}"
          else
            @locale_hash[line_no] = { :modified_line => nil,:keyname => nil,:replaced_text => nil, :path => nil }
            new_lines << "#{whitespace_indentation}#{orig_line}"
          end
        end
        raise NothingToTranslate if !file_has_been_parsed
        new_lines.join("\n")
      end
      
      private
      
      def validate_haml(haml)
        parser = Haml::Parser.new(haml, Haml::Options.new)
        parser.parse
        rescue Haml::SyntaxError
          raise InvalidSyntax, "invalid syntax for haml #{@haml_reader.path}"
      end
      
    end
  end
end
