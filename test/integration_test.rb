module Haml
  class IntegrationTest < MiniTest::Unit::TestCase

    def setup
      TestHelper.setup_project_directory!
      @workflow = TestHelper.mock_full_project_user_interaction!
    end

    def teardown
      TestHelper.teardown_project_directory!
    end

    test "it can handle namespaced views" do
      namespaced_extractor = Haml::I18n::Extractor.extractors.select{|ex| ex.haml_writer.path.match /namespace/ }.last
      assert namespaced_extractor.yaml_tool.yaml_hash["en"]["namespace"], "namespace key works"
    end

    test "it can handle partial views" do
      partial_extractor = Haml::I18n::Extractor.extractors.select{|ex| ex.haml_writer.path.match /_partial/ }.last
      assert partial_extractor.yaml_tool.yaml_hash["en"]["view2"]["partial"], "partial filenames in yaml are w/out leading _"
    end

    ## EXAMPLES

    test "it can replace a string body and have expected output ex4" do
      expected_output = File.read(file_path("ex4.output.haml"))
      assert_equal Haml::I18n::Extractor.new(file_path("ex4.haml")).new_body, expected_output
    end

    test "it can replace a string body and have expected output ex3" do
      expected_output = File.read(file_path("ex3.output.haml"))
      assert_equal Haml::I18n::Extractor.new(file_path("ex3.haml")).new_body, expected_output
    end

    test "it can replace a string body and have expected output ex2" do
      expected_output = File.read(file_path("ex2.output.haml"))
      assert_equal Haml::I18n::Extractor.new(file_path("ex2.haml")).new_body, expected_output
    end


    test "it can replace a string body and have expected output ex1" do
      expected_output = File.read(file_path("ex1.output.haml"))
      assert_equal Haml::I18n::Extractor.new(file_path("ex1.haml")).new_body, expected_output
    end



  end
end
