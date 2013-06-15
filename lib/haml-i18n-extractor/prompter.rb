require 'highline'
require 'highline/import'

module Haml
  module I18n
    class Extractor
      class Prompter

        include Helpers::Highline

        def ask_user(orig_line, replaced_line)
          say(highlight("Replace this line:"))
          say("\n")
          say(orig_line.inspect)
          say("\n")
          say(highlight("With this line?"))
          say("\n")
          say(replaced_line.inspect)
          say("\n")
          answer = ask(highlight('y/n/e?')) do |q|
                     q.echo      = false
                     q.character = true
                     q.validate  = /\A[yne]\Z/
          end
          Haml::I18n::Extractor::UserAction.new(answer)
        end

        def output_stats(file_count, file_names)
          say(highlight("Wowza! Found #{file_count} haml files!\n\n", :red))
          say("#{file_names}\n\n")
        end

        def process(haml_path, type)
          say(highlight("#{type}-d file") + " #{haml_path}\n\n")
        end

        def end_message
          say(highlight("\n\n\nNow run a git diff or such and see what changed!"))
        end

        def not_processing(haml_path)
          say(highlight("Not processing") + " file #{haml_path}.")
        end

        def syntax_error(haml_path)
          say("Haml Syntax error fo #{haml_path}. Please inspect further.")
        end

        CHOICES = {O: :overwrite, D: :dump, N: :next}

        def process_file?(file, file_index)
          o = %{[#{highlight(:O)}]verwrite}
          d = %{[#{highlight(:D)}]ump}
          n = %{[#{highlight(:N)}]ext}
          say("#{o} OR #{d} OR #{n}\n")
          say("Choose the right option for")
          say("#{highlight(file_index)} #{highlight(file)}")
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

      end
    end
  end
end


