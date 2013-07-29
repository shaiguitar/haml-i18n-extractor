module Haml
  module I18n
    class Extractor
      class Workflow

        attr_reader :extractors

        def initialize(project_path)
          @extractors = []
          @project_path = project_path
          @prompter = Haml::I18n::Extractor::Prompter.new
          unless File.directory?(@project_path)
            raise Extractor::NotADirectory, "#{@project_path} needs to be a directory!"
          end
        end

        def files
          @haml_files ||= Dir.glob(@project_path + "/**/*").select do |file|
           file.match /.haml$/
          end
        end

        def start_message
          file_count = files.size
          file_names = files.join("\n")
          @prompter.start_message(file_count, file_names)
        end

        def process_file?(file)
          file_index = index_for(file)
          @prompter.process_file?(file, file_index)
        end

        def run
          start_message
          files.each do |haml_path|
            type = process_file?(haml_path)
            if type
              process(haml_path, type)
            else
              @prompter.not_processing(haml_path)
            end
          end
        end_message
        end

        private

        def end_message
          @prompter.end_message
        end

        def index_for(file)
          (files.index(file) + 1).to_s
        end

        def process(haml_path, type)
          @prompter.process(haml_path, type)
          options = {:type => type} # overwrite or dump haml
          options.merge!({:prompt_per_line => true}) # per-line prompts
          begin
            @extractor = Haml::I18n::Extractor.new(haml_path, options)
            @extractors << @extractor
            @extractor.run
          rescue Haml::I18n::Extractor::InvalidSyntax
            @prompter.syntax_error(haml_path)
          end
        end
      end
    end
  end
end
