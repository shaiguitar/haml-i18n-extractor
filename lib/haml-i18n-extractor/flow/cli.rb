class Haml::I18n::Extractor
  class CLI

    class CliError < StandardError; end

    DEFAULT_OPTIONS = {
      interactive: false,
      type: :overwrite,
      yaml_file: 'config/locales/en.yml',
      i18n_scope: :en
    }

    def self.start(*args)
      new(*args).start
    end

    def initialize(path, options = {})
      @path = path
      @options = DEFAULT_OPTIONS.merge(options)
      @prompter = Haml::I18n::Extractor::Prompter.new
    end

    def start
      paths.each do |path|
        if File.exist?(path) && !File.directory?(path)
          Haml::I18n::Extractor.run(path, options)
        end
      end
    end

    private

    attr_reader :path, :options

    def paths
      if path
        @paths ||= File.directory?(path) ? Dir[File.join(path,'**/*.haml')] : Dir[path]
      else
        @prompter.puts("You must supply a path.")
        @prompter.puts("See haml-i18n-extractor --help below:")
        raise CliError
      end
    end

  end
end
