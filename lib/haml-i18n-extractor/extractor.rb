module Haml
  module I18n
    class Extractor

      def self.debug?
        ENV['DEBUG']
      end
      
      class InvalidSyntax < StandardError ; end
      class NotADirectory < StandardError ; end
      class NothingToTranslate < StandardError ; end
      class NotDefinedLineType < StandardError ; end

      LINE_TYPES_ALL = [:text, :not_text, :loud, :silent, :element]
      LINE_TYPES_ADD_EVAL = [:text, :element]
      
      attr_reader :haml_reader, :haml_writer
      attr_reader :locale_hash, :yaml_tool, :type

      def initialize(haml_path, opts = {})
        @type = opts[:type]
        @haml_reader = Haml::I18n::Extractor::HamlReader.new(haml_path)
        validate_haml(@haml_reader.body)
        @haml_writer = Haml::I18n::Extractor::HamlWriter.new(haml_path, {:type => @type})
        @yaml_tool = Haml::I18n::Extractor::YamlTool.new
        # hold all the processed lines
        @body = [] 
        # holds a line_no => {info_about_line_replacemnts_or_not}
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

     def new_body
        file_has_replaceable_lines = false
        @haml_reader.lines.each_with_index do |orig_line, line_no|
          file_has_replaceable_lines |= process_line(orig_line,line_no)
        end
        raise NothingToTranslate if !file_has_replaceable_lines
        @body.join("\n")
      end

      def process_line(orig_line, line_no)
        orig_line.chomp!
        orig_line, whitespace = handle_line_whitespace(orig_line)
        line_type, line_match = handle_line_finding(orig_line)
        is_replaced, replaced_text = handle_line_replacing(orig_line, line_match, line_type, line_no)
        add_to_body("#{whitespace}#{replaced_text}")
        return is_replaced
      end

      private

      def handle_line_replacing(orig_line, line_match, line_type, line_no)
        if line_match && !line_match.empty?
          replacer = Haml::I18n::Extractor::TextReplacer.new(orig_line, line_match, line_type)
          @locale_hash[line_no] = replacer.replace_hash.dup.merge!({:path => @haml_reader.path })
          [ true, replacer.replace_hash[:modified_line] ]
        else
          @locale_hash[line_no] = { :modified_line => nil,:keyname => nil,:replaced_text => nil, :path => nil }
          [ false, orig_line ]
        end
      end

      def handle_line_finding(orig_line)
        Haml::I18n::Extractor::TextFinder.new(orig_line).process_by_regex
      end

      def handle_line_whitespace(orig_line)
        orig_line.rstrip.match(/([ \t]+)?(.*)/)
        whitespace_indentation = $1
        orig_line = $2
        [ orig_line, whitespace_indentation ]
      end

      def add_to_body(ln)
        @body << ln
      end
      
      def validate_haml(haml)
        parser = Haml::Parser.new(haml, Haml::Options.new)
        parser.parse
        rescue Haml::SyntaxError
          raise InvalidSyntax, "invalid syntax for haml #{@haml_reader.path}"
      end
      
    end
  end
end
