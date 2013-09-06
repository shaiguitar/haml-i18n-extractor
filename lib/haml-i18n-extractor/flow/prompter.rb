require 'highline'
require 'highline/import'

module Haml
  module I18n
    class Extractor
      class Prompter

        include Helpers::Highline

        def puts(txt)
          say(txt)
        end

        def ask_user(orig_line, replaced_line)
          say(highlight("Replace this line:"))
          say("\n")
          say(orig_line.inspect)
          say("\n")
          say(highlight("With this line?"))
          say("\n")
          say(replaced_line.inspect)
          say("\n")
          answer = ask(highlight('[y]es/[n]o/[t]ag/[N]ext?')) do |q|
            q.echo      = false
            q.character = true
            q.validate  = /\A[yntN]\Z/
          end
          Haml::I18n::Extractor::UserAction.new(answer)
        end

        def start_message(file_count, file_names)
          say("Hello there kind sir! Read this if its your first time:")
          say("(1) overwrite a file")
          say("(2) dump the file to a temp file")
          say("(3) Skip processing it")
          say("Once you are processing a file, you should be able to:")
          say("(1) replace the line with what it's found. this will add yaml info as well.")
          say("(2) skip - don't replace the line and put yaml info.")
          say("(3) tag - keep a reminder of this place in the code and put it in a file for later review.")
          say(highlight("Okay then! Found #{file_count} haml files!\n\n", :red))
          say("#{file_names}\n\n")
        end

        def end_message
          say("\n\n\n")
          say(highlight("Now run a git diff or such and see what changed!"))
          say(highlight("Check #{Haml::I18n::Extractor::TaggingWriter::DB} if you have tagged any lines."))
          say("PS: If you have any feedback or ideas how this would be better, feel free to open an issue on github. See README for more info.")
        end

        def process(haml_path, type)
          say(highlight("#{type}-d file") + " #{haml_path}\n\n")
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

        def moving_to_next_file
          say("Next received! Saved changes done so far, moving to the next file.\n")
        end
      end
    end
  end
end


