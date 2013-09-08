require 'test_helper'

module Haml
  class IntegrationTest < MiniTest::Unit::TestCase

    def setup
      TestHelper.setup_project_directory!
      @workflow = TestHelper.mock_full_project_user_interaction!
    end

    def teardown
      TestHelper.teardown_project_directory!
    end

    def test_it_can_handle_namespaced_views
      namespaced_extractor = Haml::I18n::Extractor.extractors.select{|ex| ex.haml_writer.path.match /namespace/ }.last
      assert namespaced_extractor.yaml_writer.yaml_hash["en"]["namespace"], "namespace key works"
    end

    def test_it_can_handle_partial_views
      partial_extractor = Haml::I18n::Extractor.extractors.select{|ex| ex.haml_writer.path.match /_partial/ }.last
      assert partial_extractor.yaml_writer.yaml_hash["en"]["view2"]["partial"], "partial filenames in yaml are w/out leading _"
    end

    ## EXAMPLES
    #
    def test_it_can_replace_a_string_body_and_have_expected_output_ex6
      expected_output = File.read(file_path("ex6.output.haml"))
      assert_equal Haml::I18n::Extractor.new(file_path("ex6.haml")).new_body, expected_output
    end

    def test_it_can_replace_a_string_body_and_have_expected_output_ex5
      expected_output = File.read(file_path("ex5.output.haml"))
      assert_equal Haml::I18n::Extractor.new(file_path("ex5.haml")).new_body, expected_output
    end

    def test_it_can_replace_a_string_body_and_have_expected_output_ex4
      expected_output = File.read(file_path("ex4.output.haml"))
      assert_equal Haml::I18n::Extractor.new(file_path("ex4.haml")).new_body, expected_output
    end

    def test_it_can_replace_a_string_body_and_have_expected_output_ex3
      expected_output = File.read(file_path("ex3.output.haml"))
      assert_equal Haml::I18n::Extractor.new(file_path("ex3.haml")).new_body, expected_output
    end

    def test_it_can_replace_a_string_body_and_have_expected_output_ex2
      expected_output = File.read(file_path("ex2.output.haml"))
      assert_equal Haml::I18n::Extractor.new(file_path("ex2.haml")).new_body, expected_output
    end

    def test_it_can_replace_a_string_body_and_have_expected_output_ex1
      expected_output = File.read(file_path("ex1.output.haml"))
      assert_equal Haml::I18n::Extractor.new(file_path("ex1.haml")).new_body, expected_output
    end

  end
end
