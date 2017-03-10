require 'yaml'
require 'pathname'
require 'haml-i18n-extractor/core-ext/hash'
require 'active_support/hash_with_indifferent_access'

module Haml
  module I18n
    class Extractor
      class YamlWriter

        attr_accessor :info_for_yaml, :yaml_file, :i18n_scope

        include Helpers::StringHelpers

        def initialize(i18n_scope = nil, yaml_file = nil, options = {})
          @i18n_scope = i18n_scope && i18n_scope.to_sym || :en
          @options = options
          if (options[:add_filename_prefix])
            @dir_prefix_including_filename = options[:haml_path].gsub(options[:base_path], '').gsub(/(\.html)?\.haml/, '')

            dir_prefix_parts = @dir_prefix_including_filename.split('/')
            dir_prefix_without_filename = dir_prefix_parts.first dir_prefix_parts.size - 1
            @dir_prefix = dir_prefix_without_filename.join('/')
            @yaml_file = "./config/locales/#{@i18n_scope}/#{@dir_prefix}/#{@i18n_scope}.yml"
          else
            @yaml_file = yaml_file || "./config/locales/#{@i18n_scope}.yml"
          end
          locales_dir = Pathname.new(@yaml_file).dirname
          if ! File.exist?(locales_dir)
            FileUtils.mkdir_p(locales_dir)
          end
        end

        # converts the blob of info passed into it into i18n yaml like
        # {:en => {:view_name => {:key_name => :string_name } } }
        def yaml_hash
          yml = Hash.new
          @info_for_yaml.map do |line_no, info_array|
            info_array.each_with_index do |info, index|
              unless info[:t_name].nil?
                keyspace = [@i18n_scope,standardized_viewnames(info[:path]), info[:t_name],
                            normalize_interpolation(info[:replaced_text])].flatten
                yml.deep_merge!(nested_hash({},keyspace))
              end
            end
          end
          yml = hashify(yml)

        end

        def write_file(filename = nil)
          pth = filename.nil? ? @yaml_file : filename
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
          f.puts final_yaml_hash.to_yaml(:line_width => 400)
          f.flush
        end

        private

        # {:foo => {:bar => {:baz => :mam}, :barrr => {:bazzz => :mammm} }}
        def hashify(my_hash)
          if my_hash.is_a?(Hash)
            result = Hash.new
            my_hash.each do |k, v|
              is_leaf_node = !v.is_a?(Hash)
              if (@options[:add_filename_prefix] && is_leaf_node)
                filename = File.basename(@dir_prefix_including_filename)
                path_without_filename = @dir_prefix_including_filename.gsub(@options[:base_path], '').gsub(filename, '')
                filename_without_leading_underscore = filename.gsub(/^_/, "")
                path_with_corrected_filename = path_without_filename.to_s + filename_without_leading_underscore.to_s
                dir_prefix_to_dots = (path_with_corrected_filename + '/').gsub('/', '.')
                key_without_dir_prefix = k.to_s.gsub(dir_prefix_to_dots, '')
                result[key_without_dir_prefix] = v
              else
                result[k.to_s] = hashify(v)
              end
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

        # assuming rails format, app/views/users/index.html.haml return [users]
        # app/views/admin/users/index.html.haml return [admin, users]
        # app/views/admin/users/with_namespace/index.html.haml return [admin, users, with_namespace, index]
        # otherwise, just grab the last one.
        def standardized_viewnames(pth)
          pathname = Pathname.new(pth)
          array_of_dirs = pathname.dirname.to_s.split("/")
          view_name = pathname.basename.to_s.gsub(/.html.haml$/,"").gsub(/.haml$/,"")
          view_name.gsub!(/^_/, "")

          index = array_of_dirs.index("views")

          if (@options[:add_filename_prefix])
            array_of_dirs = pathname.dirname.to_s.gsub(@options[:base_path], '').split("/")
            array_of_dirs << view_name
          else
            if index
              array_of_dirs[index+1..-1] << view_name
            else
              [array_of_dirs.last] << view_name
            end
          end
        end

      end
    end
  end
end
