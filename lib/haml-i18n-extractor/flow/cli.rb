class Haml::I18n::Extractor
  class CLI

    class CliError < StandardError; end

    def initialize(opts)
      @options = opts || {}
      @prompter = Haml::I18n::Extractor::Prompter.new # may as well
    end

    def self.option_parser
      option_parser = Trollop::Parser.new do
        banner <<-EOB

  haml-i18n-extractor --version # print version of this gem
  haml-i18n-extractor --help    # this message
  haml-i18n-extractor <path> [--interactive|--non-interactive] [--other-options]

  See options list (short options available next to long option):\n

        EOB
        version "Current version: #{Haml::I18n::Extractor::VERSION}"
        opt :interactive, "interactive mode", :short => 'i'
        opt :non_interactive, "non interactive mode", :short => 'n'
        opt :yaml_file, "yaml file path, defaults to config/locales/en.yml", :type => String, :short => 'y'
        opt :i18n_scope, "top level i18n scope, defaults to :en", :type => String, :short => 's'
      end
    end

    def self.show_help!
      Trollop::with_standard_exception_handling option_parser do
        raise Trollop::HelpNeeded
      end
    end

    def start
      check_interactive_or_not_passed
      if @options[:path]
        check_interactive_or_not_passed
        pth = File.expand_path(@options[:path])

        if File.directory?(pth)
          workflow = Haml::I18n::Extractor::Workflow.new(pth, @options)
          workflow.run
        elsif File.exists?(pth)
          @options.merge!(:type => :overwrite)
          extractor = Haml::I18n::Extractor.new(pth, @options)
          extractor.run
        end
      end
    end

    private

    def check_interactive_or_not_passed
      if (!@options[:interactive] && !@options[:non_interactive]) || (@options[:interactive] && @options[:non_interactive])
        @prompter.puts("You must choose either one of interactive mode or non interactive mode.")
        @prompter.puts("See haml-i18n-extractor --help below:")
        raise CliError
      end
    end
  end
end
