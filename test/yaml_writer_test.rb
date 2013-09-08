require 'test_helper'

module Haml
  class YamlWriterTest < MiniTest::Unit::TestCase

    def setup
      @temp_locale_dir = "./test/tmp/"
      TestHelper.setup_project_directory!
    end

    def setup_info_for_yaml
      @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"))
      @ex1.run
    end

    def locale_config_dir
      dir = File.expand_path(File.join(File.dirname(__FILE__), "/tmp/config/locales"))
      if ! File.exists?(dir)
        FileUtils.mkdir_p(dir)
      end
      dir
    end

    def locale_config_file
      File.join(locale_config_dir, "en.yml")
    end

    def setup_yaml_file
      File.open(locale_config_file, "w+") do |f|
        f.write(existing_yaml_hash.to_yaml)
      end
    end

    def existing_yaml_hash
      {"en" => {
        "viewname" => {
          "translate_key" => "Translate Key"
        }
      }
      }
    end

    def ex1_yaml_hash
      YAML.load File.read(file_path("ex1.yml"))
    end

    def ex5_yaml_hash
      YAML.load File.read(file_path("ex5.yml"))
    end

    def ex6_yaml_hash
      YAML.load File.read(file_path("ex6.yml"))
    end

    def test_it_can_deal_with_interpolated_vars
      @ex5 = Haml::I18n::Extractor.new(file_path("ex5.haml"))
      @ex5.run
      assert_equal @ex5.yaml_writer.yaml_hash, ex5_yaml_hash
    end

    def test_it_can_deal_with_utf8_characters
      @ex6 = Haml::I18n::Extractor.new(file_path("ex6.haml"))
      @ex6.run
      assert_equal @ex6.yaml_writer.yaml_hash, ex6_yaml_hash
    end

    def test_defaults_for_empty_init
      yaml_writer = Haml::I18n::Extractor::YamlWriter.new
      assert_equal yaml_writer.yaml_file, "./config/locales/en.yml"
      assert_equal yaml_writer.i18n_scope, :en
    end

    def test_you_can_pass_a_yaml_file
      yaml_writer = Haml::I18n::Extractor::YamlWriter.new(nil, @temp_locale_dir)
      assert_equal yaml_writer.yaml_file, @temp_locale_dir
    end

    def test_it_can_merge_with_an_existing_yml_file
      setup_info_for_yaml
      setup_yaml_file
      @ex1.yaml_writer.write_file(locale_config_file)
      really_written = YAML.load(File.read(locale_config_file))
      assert_equal really_written['en']['viewname'], existing_yaml_hash['en']['viewname']
      assert_equal really_written['en']['support'], ex1_yaml_hash['en']['support']
    end

    def test_it_can_accept_a_different_yml_file
      @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"), {:yaml_file => "/tmp/foo.yml"})
      assert_equal @ex1.yaml_writer.yaml_file, "/tmp/foo.yml"
    end

    def test_it_knows_about_i18n_scope
      @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"), {:i18n_scope => "he"})
      assert_equal @ex1.yaml_writer.i18n_scope, :he
    end

    def test_it_knows_about_i18n_scope_defaults_to_en
      @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"))
      assert_equal @ex1.yaml_writer.i18n_scope, :en
    end

    def test_it_will_assume_yaml_file_according_to_i18n_scope_if_no_yaml_file_is_passed
      yaml_writer = Haml::I18n::Extractor::YamlWriter.new("he", nil)
      assert_equal yaml_writer.yaml_file, "./config/locales/he.yml"
    end

    def test_it_will_not_assume_yaml_file_according_to_i18n_scope_if_yaml_file_is_passed
      yaml_writer = Haml::I18n::Extractor::YamlWriter.new("he", "/tmp/foo.yml")
      assert_equal yaml_writer.yaml_file, "/tmp/foo.yml"
    end

    def test_it_relies_on_the_info_for_yaml_having_a_certain_format
      setup_info_for_yaml
      @ex1.yaml_writer.info_for_yaml.each do |line_no, info_for_line|
        assert info_for_line.has_key?(:modified_line), "hash info has :modified_line key"
        assert info_for_line.has_key?(:t_name), "hash info has :t_name key"
        assert info_for_line.has_key?(:replaced_text), "hash info has :replaced_text key"
        # FIXME: since the scope right now is we're running this per file this will be the same, but keeping this right now.
        assert info_for_line.has_key?(:path), "hash info has :path key"
      end
    end

    def test_constructs_a_yaml_hash_according_to_the_view_in_rails_mode
      setup_info_for_yaml
      yaml_writer = @ex1.yaml_writer
      assert_equal yaml_writer.yaml_hash, ex1_yaml_hash
    end

  end
end
