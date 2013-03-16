require 'yaml'
require 'pathname'
require 'haml-i18n-extractor/core-ext/hash'
require 'active_support/hash_with_indifferent_access'

module Haml
  module I18n
    class Extractor
      class YamlTool
        
        attr_accessor :locales_dir, :locale_hash

        def initialize(locales_dir = nil)
          if locales_dir
            @locales_dir = locales_dir
          else
            # locales_dir = rails_mode? ? (Rails.root.to_s + "/config/locales") : "."
            @locales_dir = File.expand_path(".")
          end
        end

        # {:en => {:view_name => {:key_name => :string_name } } }
        def yaml_hash
          h = HashWithIndifferentAccess.recursive_init
          @locale_hash.map do |line_no, info|
            unless info[:keyname].nil?
              h[i18n_scope][standardized_viewname(info[:path])][standarized_keyname(info[:keyname])] = info[:replaced_text]
            end
          end
          h
        end

        def locale_file
          if @locale_hash
            pth = @locale_hash.map{|_,h| h[:path] }.compact.first
            if pth
              full_path = Pathname.new(pth)
              base_name = full_path.basename.to_s
              File.expand_path(File.join( @locales_dir, standardized_viewname(full_path) + ".#{base_name}.yml"))
            end
          end.to_s
        end
        
        def write_file
          f = File.open(locale_file, "w+")
          f.puts yaml_hash.to_yaml
          f.flush
        end
        
        private

        def i18n_scope
          :en
        end

        # comes in like "t('.some_place')", return .some_place
        def standarized_keyname(name)
          name.match(/t\('\.(.*)'\)/)
          $1
        end

        # assuming rails format, app/views/users/index.html.haml return users
        def standardized_viewname(pth)
          Pathname.new(pth).dirname.to_s.split("/").last
        end

        # def rails_mode?
        #   defined?(Rails)
        # end

      end
    end
  end
end