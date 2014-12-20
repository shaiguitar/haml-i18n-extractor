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
      @path, @options = path, DEFAULT_OPTIONS.merge(options)
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
      @paths ||= File.directory?(path) ? Dir[File.join(path,'**/*.haml')] : Dir[path]
    end

  end
end
