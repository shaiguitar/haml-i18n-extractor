module Haml
  module I18n
    class Extractor

      def self.debug?
        ENV['DEBUG_EXTRACTOR']
      end

      # helpful for debugging
      def self.extractors
        @extractors ||= []
      end

      class InvalidSyntax < StandardError ; end
      class NotADirectory < StandardError ; end
      class NotDefinedLineType < StandardError ; end
      class AbortFile < StandardError ; end

      LINE_TYPES_ALL = [:plain, :script, :silent_script, :haml_comment, :tag, :comment, :doctype, :filter, :root]
      LINE_TYPES_ADD_EVAL = [:plain, :tag, :script]

      attr_reader :haml_reader, :haml_writer
      attr_reader :info_for_yaml, :yaml_writer, :type
      attr_reader :current_line

      def initialize(haml_path, opts = {})
        @options = opts
        @type = @options[:type]
        @interactive = @options[:interactive]
        @prompter = Haml::I18n::Extractor::Prompter.new
        @haml_reader = Haml::I18n::Extractor::HamlReader.new(haml_path)
        validate_haml(@haml_reader.body)
        @haml_writer = Haml::I18n::Extractor::HamlWriter.new(haml_path, {:type => @type})
        @yaml_writer = Haml::I18n::Extractor::YamlWriter.new(@options[:i18n_scope], @options[:yaml_file])
        @tagging_writer ||= Haml::I18n::Extractor::TaggingWriter.new
        # hold all the processed lines
        @body = []
        # holds a line_no => {info_about_line_replacemnts_or_not}
        @info_for_yaml = {}

        self.class.extractors << self
      end

      def run
        assign_replacements
        validate_haml(@haml_writer.body)
        @yaml_writer.write_file
        @haml_writer.write_file
      end

      def assign_new_body
        @haml_writer.body = new_body
      end

      def assign_yaml
        @yaml_writer.info_for_yaml = @info_for_yaml
      end

      def assign_replacements
        assign_new_body
        assign_yaml
      end

      def new_body
        begin
          @current_line = 1
          @haml_reader.lines.each do |orig_line|
            process_line(orig_line, @current_line)
            @current_line += 1
          end
        rescue AbortFile
          @prompter.moving_to_next_file
          add_rest_of_file_to_body(@current_line)
        end
        @body.join("\n") + "\n"
      end

      # this is the bulk of it:
      # where we end up setting body info and info_for_yaml.
      # not _write_, just set that info in memory in correspoding locations.
      # refactor more?
      def process_line(orig_line, line_no)
        orig_line.chomp!
        orig_line, whitespace = handle_line_whitespace(orig_line)
        finder_result = finding_result(orig_line, line_no)
        replacer_result = replacement_result(orig_line, finder_result.match, finder_result.type, line_no)
        should_be_replaced = replacer_result.should_be_replaced
        text_to_replace = replacer_result.modified_line

        user_action = should_be_replaced ? user_action_yes : user_action_no

        if should_be_replaced
          if interactive?
            user_action = @prompter.ask_user(orig_line,text_to_replace)
          end
        end

        if user_action.tag?
          @tagging_writer.write(@haml_reader.path, line_no)
          add_to_body("#{whitespace}#{orig_line}")
        elsif user_action.next?
          raise AbortFile, "stopping to process the rest of the file"
       elsif user_action.replace_line?
          add_to_yaml_info(line_no, replacer_result.info)
          add_to_body("#{whitespace}#{text_to_replace}")
        elsif user_action.no_replace?
          add_to_yaml_info(line_no, Haml::I18n::Extractor::ReplacerResult.new(nil,nil,nil,false,nil).info)
          add_to_body("#{whitespace}#{orig_line}")
        end

        return should_be_replaced
      end

      def interactive?
        !!@interactive
      end

      private

      def add_rest_of_file_to_body(line_no)
        @haml_reader.lines[line_no-1..@haml_reader.lines.size-1].map do |orig_ln|
          add_to_body(orig_ln.chomp)
        end
      end

      def replacement_result(orig_line, line_match, line_type, line_no)
        if line_match && !line_match.empty?
          Haml::I18n::Extractor::TextReplacer.new(orig_line, line_match, line_type, @haml_reader.path, line_metadata(line_no)).result
        else
          Haml::I18n::Extractor::ReplacerResult.new(orig_line, nil,line_match, false, "")
        end
      end

      def add_to_yaml_info(line_no, hash)
        @info_for_yaml[line_no] = hash
      end

      def finding_result(orig_line,lineno)
        Haml::I18n::Extractor::TextFinder.new(orig_line,line_metadata(lineno)).process_by_regex
      end

      def line_metadata(lineno)
        @haml_reader.metadata[lineno]
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

      def user_action_yes
        Haml::I18n::Extractor::UserAction.new('y') # default if no prompting: just do it.
      end

      def user_action_no
        Haml::I18n::Extractor::UserAction.new('n') # don't replace
      end


      def validate_haml(haml)
        parser = Haml::Parser.new(haml, Haml::Options.new)
        parser.parse
      rescue Haml::SyntaxError => e
        message = "invalid syntax for haml #{@haml_reader.path}\n"
        message << "original error:\n"
        message << e.message
        raise InvalidSyntax, message
      end

    end
  end
end
