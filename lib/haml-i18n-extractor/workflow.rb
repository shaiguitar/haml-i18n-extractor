require 'highline'
require 'highline/import'

module Haml
  module I18n
    class Extractor
      class Workflow

        include Helpers::Highline

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


        # FIXME, use prompter to do any prompting in this class TODO
        #
        def output_stats
          say(highlight("Wowza! Found #{files.size} haml files!\n\n", :red))
          say("#{files.join("\n")}\n\n")
        end

        CHOICES = {O: :overwrite, D: :dump, N: :next}

        def process_file?(file)
          o = %{[#{highlight(:O)}]verwrite}
          d = %{[#{highlight(:D)}]ump}
          n = %{[#{highlight(:N)}]ext}
          say("#{o} OR #{d} OR #{n}\n")
          say("Choose the right option for")
          say("#{index_for(file)} #{highlight(file)}")
          choices = CHOICES.keys.map(&:to_s)
          prompt = "Your choice #{highlight(choices)}?"
          answer = ask(prompt) do |q|
                     q.echo      = false
                     q.character = true
                     q.validate  = /\A[#{choices}r]\Z/
                   end
          return :overwrite if answer == 'O'
          return :overwrite if answer == 'R' # cheat 'replace'
          return :dump if answer == 'D'
        end

        def run
          output_stats
          files.each do |haml_path|
            type = process_file?(haml_path)
            if type
              process(haml_path, type)
            else
              say(highlight("Not processing") + " file #{haml_path}.")
            end
          end
        end_message
        end

        private

        def end_message
          say(highlight("\n\n\nNow run a git diff or such and see what changed!"))
        end

        def index_for(file)
          highlight((files.index(file) + 1).to_s)
        end

        def process(haml_path, type)
          say(highlight("#{type}-d file") + " #{haml_path}\n\n")
          options = {:type => type} # overwrite or dump haml
          options.merge!({:prompt_per_line => true}) # per-line prompts
          begin
            @ex1 = Haml::I18n::Extractor.new(haml_path, options)
            @ex1.run
          rescue Haml::I18n::Extractor::InvalidSyntax
            say("Haml Syntax error fo #{haml_path}. Please inspect further.")
          end
        end
      end
    end
  end
end
