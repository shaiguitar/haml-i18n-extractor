require 'yaml'
require 'pathname'
require 'haml-i18n-extractor/core-ext/hash'
require 'active_support/hash_with_indifferent_access'

module Haml
  module I18n
    class Extractor
      class YamlTool

        attr_accessor :locales_dir, :locale_hash

        # this requires passing an absolute path.
        # meaning run from a given rails root...
        # ok? change?
        def initialize(locales_dir = nil)
          @locales_dir = locales_dir ? locales_dir : "./config/locales/"
          if ! File.exists?(@locales_dir)
            FileUtils.mkdir_p(@locales_dir)
          end
        end

        # {:en => {:view_name => {:key_name => :string_name } } }
        def yaml_hash
          yml = HashWithIndifferentAccess.recursive_init
          @locale_hash.map do |line_no, info|
            unless info[:keyname].nil?
              yml[i18n_scope][standardized_viewname(info[:path])][standarized_keyname(info[:keyname])] = info[:replaced_text]
            end
          end
          yml = hashify(yml)
        end

        def locale_file
          File.join(@locales_dir, "#{i18n_scope}.yml")
        end

        def write_file(filename = nil)
          f = filename.nil? ? locale_file : filename
          f = File.open(f, "w+")
          f.puts yaml_hash.to_yaml
          f.flush
        end

        private

        # {:foo => {:bar => {:baz => :mam}, :barrr => {:bazzz => :mammm} }}
        def hashify(my_hash)
          if my_hash.is_a?(HashWithIndifferentAccess)
            result = Hash.new
            my_hash.each do |k, v|
              result[k.to_s] = hashify(v)
            end
            result
          else
            my_hash
          end
        end

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

     end
    end
  end
end
