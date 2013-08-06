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
      {"en"=>
       {"support" =>
        {"ex1" =>
          {"some_place"=>"Some place",
           "admin"=>"Admin",
           "admin_dashboard"=>"Admin Dashboard",
           "stacks"=>"Stacks",
           "alerts"=>"t('.alerts')",
           "accounts"=>"Accounts",
           "what_is_supposed_to_be_is_supp"=>
          "What is@ supposed to be, is supposed to be! ~"
          }
        }
       }
      }
    end

    test "defaults for empty init" do
      yaml_tool = Haml::I18n::Extractor::YamlTool.new
      assert_equal yaml_tool.yaml_file, "./config/locales/en.yml"
      assert_equal yaml_tool.i18n_scope, :en
    end

    test "you can pass a yaml_file" do
      yaml_tool = Haml::I18n::Extractor::YamlTool.new(nil, @temp_locale_dir)
      assert_equal yaml_tool.yaml_file, @temp_locale_dir
    end

    test "it can merge with an existing yml file" do
      setup_locale_hash
      setup_yaml_file
      @ex1.yaml_tool.write_file(locale_config_file)
      really_written = YAML.load(File.read(locale_config_file))
      assert_equal really_written['en']['viewname'], existing_yaml_hash['en']['viewname']
      assert_equal really_written['en']['support'], ex1_yaml_hash['en']['support']
    end

    test "it can accept a different yml file" do
      @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"), {:yaml_file => "/tmp/foo.yml"})
      assert_equal @ex1.yaml_tool.yaml_file, "/tmp/foo.yml"
    end

    test "it knows about i18n scope" do
      @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"), {:i18n_scope => "he"})
      assert_equal @ex1.yaml_tool.i18n_scope, :he
    end

    test "it knows about i18n scope, defaults to :en" do
      @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"))
      assert_equal @ex1.yaml_tool.i18n_scope, :en
    end

    test "it will assume yaml_file according to i18n_scope if no yaml_file is passed" do
      yaml_tool = Haml::I18n::Extractor::YamlTool.new("he", nil)
      assert_equal yaml_tool.yaml_file, "./config/locales/he.yml"
    end

    test "it will not assume yaml_file according to i18n_scope if yaml_file is passed" do
      yaml_tool = Haml::I18n::Extractor::YamlTool.new("he", "/tmp/foo.yml")
      assert_equal yaml_tool.yaml_file, "/tmp/foo.yml"
    end

    test "it relies on the locale_hash having a certain format" do
      setup_locale_hash
      @ex1.yaml_tool.locale_hash.each do |line_no, info_for_line|
        assert info_for_line.has_key?(:modified_line), "hash info has :modified_line key"
        assert info_for_line.has_key?(:keyname), "hash info has :keyname key"
        assert info_for_line.has_key?(:replaced_text), "hash info has :replaced_text key"
        # FIXME: since the scope right now is we're running this per file this will be the same, but keeping this right now.
        assert info_for_line.has_key?(:path), "hash info has :path key"
      end
    end

    test "constructs a yaml hash according to the view in rails mode" do
      setup_locale_hash
      yaml_tool = @ex1.yaml_tool
      assert_equal yaml_tool.yaml_hash, ex1_yaml_hash
    end

  end
end
