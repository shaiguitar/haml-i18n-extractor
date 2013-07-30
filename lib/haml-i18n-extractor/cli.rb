class Haml::I18n::Extractor
  class CLI

    class CliError < StandardError; end

    def initialize(opts)
      @options = opts || {}
      @prompter = Haml::I18n::Extractor::Prompter.new # may as well
    end

    def start
      check_interactive_or_not_passed
      if @options[:path]
        check_interactive_or_not_passed
        pth = File.expand_path(@options[:path])

        if File.directory?(pth)
          workflow = Haml::I18n::Extractor::Workflow.new(pth, @options)
          workflow.run
        elsif File.exists?(pth) && @options[:interactive]
          extractor = Haml::I18n::Extractor.new(pth, :type => :overwrite, :interactive => true)
          extractor.run
        elsif File.exists?(pth) && @options[:non_interactive]
          extractor = Haml::I18n::Extractor.new(pth, :type => :overwrite, :interactive => false)
          extractor.run
        end
      end
    end

    private

    def check_interactive_or_not_passed
      if !@options[:interactive] && !@options[:non_interactive]
        @prompter.puts("You must choose either one of interactive mode or non interactive mode.")
        @prompter.puts("See haml-i18n-extractor --help")
        raise CliError
      end
    end
  end
end
