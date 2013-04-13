require 'highline'
require 'highline/import'

module Haml
  module I18n
    class Extractor
      class Workflow

        def initialize(project_path)
          @project_path = project_path
          unless File.directory?(@project_path)
            raise Extractor::NotADirectory, "#{@project_path} needs to be a directory!"
          end
        end

        def files
          @haml_files ||= Dir.glob(@project_path + "/**/*").select do |file|
           file.match /.haml$/
          end
        end

        def output_stats
          say("Found #{files.size} files:\n\n#{files.join("\n")}\n\n")
        end

        def process_file?(file)
          say("Process file #{file}?")
          say("[o]verwrite/[d]ump/[n]ext\n")
          choices = "odn"
          answer = ask("Your choice [#{choices}]? ") do |q|
                     q.echo      = false
                     q.character = true
                     q.validate  = /\A[#{choices}]\Z/
                   end
          say("Your choice: #{answer}")
          return :overwrite if answer == 'o'
          return :dump if answer == 'd'
        end

        def run
          output_stats
          files.each do |haml_path|
            if type = process_file?(haml_path)
              process(haml_path, type)
            else
              say("Not processing file #{haml_path}.")
            end
          end
        end

        private

        def process(haml_path, type)
          options = {:type => type} # overwrite or dump haml
          begin
            @ex1 = Haml::I18n::Extractor.new(haml_path, options)
            @ex1.run
          rescue Haml::I18n::Extractor::InvalidSyntax
            say("Haml Syntax error fo #{haml_path}. Please inspect further.")
          rescue Haml::I18n::Extractor::NothingToTranslate
            say("Nothing to translate for #{haml_path}")
          end
        end
        
      end
    end
  end
end
