require 'test_helper'

module Haml
  class YamlToolTest < MiniTest::Unit::TestCase

    def setup
      @temp_locale_dir = "./test/tmp/"
      TestHelper.setup_project_directory!
    end

    def setup_locale_hash
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

    def test_defaults_for_empty_init
      yaml_tool = Haml::I18n::Extractor::YamlTool.new
      assert_equal yaml_tool.yaml_file, "./config/locales/en.yml"
      assert_equal yaml_tool.i18n_scope, :en
    end

    def test_you_can_pass_a_yaml_file
      yaml_tool = Haml::I18n::Extractor::YamlTool.new(nil, @temp_locale_dir)
      assert_equal yaml_tool.yaml_file, @temp_locale_dir
    end

    def test_it_can_merge_with_an_existing_yml_file
      setup_locale_hash
      setup_yaml_file
      @ex1.yaml_tool.write_file(locale_config_file)
      really_written = YAML.load(File.read(locale_config_file))
      assert_equal really_written['en']['viewname'], existing_yaml_hash['en']['viewname']
      assert_equal really_written['en']['support'], ex1_yaml_hash['en']['support']
    end

    def test_it_can_accept_a_different_yml_file
      @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"), {:yaml_file => "/tmp/foo.yml"})
      assert_equal @ex1.yaml_tool.yaml_file, "/tmp/foo.yml"
    end

    def test_it_knows_about_i18n_scope
      @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"), {:i18n_scope => "he"})
      assert_equal @ex1.yaml_tool.i18n_scope, :he
    end

    def test_it_knows_about_i18n_scope_defaults_to_en
      @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"))
      assert_equal @ex1.yaml_tool.i18n_scope, :en
    end

    def test_it_will_assume_yaml_file_according_to_i18n_scope_if_no_yaml_file_is_passed
      yaml_tool = Haml::I18n::Extractor::YamlTool.new("he", nil)
      assert_equal yaml_tool.yaml_file, "./config/locales/he.yml"
    end

    def test_it_will_not_assume_yaml_file_according_to_i18n_scope_if_yaml_file_is_passed
      yaml_tool = Haml::I18n::Extractor::YamlTool.new("he", "/tmp/foo.yml")
      assert_equal yaml_tool.yaml_file, "/tmp/foo.yml"
    end

    def test_it_relies_on_the_locale_hash_having_a_certain_format
      setup_locale_hash
      @ex1.yaml_tool.locale_hash.each do |line_no, info_for_line|
        assert info_for_line.has_key?(:modified_line), "hash info has :modified_line key"
        assert info_for_line.has_key?(:keyname), "hash info has :keyname key"
        assert info_for_line.has_key?(:replaced_text), "hash info has :replaced_text key"
        # FIXME: since the scope right now is we're running this per file this will be the same, but keeping this right now.
        assert info_for_line.has_key?(:path), "hash info has :path key"
      end
    end

    def test_constructs_a_yaml_hash_according_to_the_view_in_rails_mode
      setup_locale_hash
      yaml_tool = @ex1.yaml_tool
      assert_equal yaml_tool.yaml_hash, ex1_yaml_hash
    end

  end
end
