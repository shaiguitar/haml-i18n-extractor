require 'test_helper'

module Haml
  class YamlToolTest < MiniTest::Unit::TestCase

    def setup
      @temp_locale_dir = File.expand_path(__FILE__) + "/tmp/"
    end

    def setup_locale_hash
      @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"))
      @ex1.run
    end

    def ex1_yaml_hash
      {"en"=>
        {"support"=>
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
    end

    # test "locale dir defaults for rails if you do not pass anything" do
    #   with_rails_mode do
    #     yaml_tool = Haml::I18n::Extractor::YamlTool.new
    #     assert_equal yaml_tool.locales_dir, "/data/current/name/config/locales"
    #   end
    # end

    test "locale dir defaults to cwd if no rails" do
      without_rails_mode do
        yaml_tool = Haml::I18n::Extractor::YamlTool.new
        assert_equal yaml_tool.locales_dir, File.expand_path(".")
      end
    end
    
    test "you can set the locale_dir" do
      yaml_tool = Haml::I18n::Extractor::YamlTool.new(@temp_locale_dir)
      assert_equal yaml_tool.locales_dir, @temp_locale_dir
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
