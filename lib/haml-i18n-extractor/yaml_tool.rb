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
          yml = Hash.new
          @locale_hash.map do |line_no, info|
            unless info[:keyname].nil?
              keyspace = [i18n_scope,standardized_viewnames(info[:path]), standarized_keyname(info[:keyname]),
                          info[:replaced_text]].flatten
              yml.deep_merge!(nested_hash({},keyspace))
            end
          end
          yml = hashify(yml)
        end

        def locale_file
          File.join(@locales_dir, "#{i18n_scope}.yml")
        end

        def write_file(filename = nil)
          pth = filename.nil? ? locale_file : filename
          if File.exist?(pth)
            str = File.read(pth)
            if str.empty?
              existing_yaml_hash = {}
            else
              existing_yaml_hash = YAML.load(str)
            end
          else
            existing_yaml_hash = {}
          end
          final_yaml_hash = existing_yaml_hash.deep_merge!(yaml_hash)
          f = File.open(pth, "w+")
          f.puts final_yaml_hash.to_yaml
          f.flush
        end

        private

        # {:foo => {:bar => {:baz => :mam}, :barrr => {:bazzz => :mammm} }}
        def hashify(my_hash)
          if my_hash.is_a?(Hash)
            result = Hash.new
            my_hash.each do |k, v|
              result[k.to_s] = hashify(v)
            end
            result
          else
            my_hash
          end
        end

        # [1,2,3] => {1 => {2 => 3}}
        def nested_hash(hash,array)
          elem = array.shift
          if array.size == 1
            hash[elem] = array.last
          else
            hash[elem] = {}
            nested_hash(hash[elem],array)
          end
          hash
        end
        def i18n_scope
          :en
        end

        # comes in like "t('.some_place')", return .some_place
        def standarized_keyname(name)
          name.match(/t\('\.(.*)'\)/)
          $1
        end

        # assuming rails format, app/views/users/index.html.haml return [users]
        # app/views/admin/users/index.html.haml return [admin, users]
        # app/views/admin/users/with_namespace/index.html.haml return [admin, users, with_namespace]
        # otherwise, just grab the last one.
        def standardized_viewnames(pth)
          array_of_dirs = Pathname.new(pth).dirname.to_s.split("/")
          index = array_of_dirs.index("views")
          if index
            array_of_dirs[index+1..-1]
          else
            [array_of_dirs.last]
          end
        end

      end
    end
  end
end
