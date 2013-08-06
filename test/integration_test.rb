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
      namespaced_extractor = @workflow.extractors.select{|ex| ex.haml_writer.path.match /namespace/ }.last
      assert namespaced_extractor.yaml_tool.yaml_hash["en"]["namespace"], "namespace key works"
    end

    test "it can handle partial views" do
      partial_extractor = @workflow.extractors.select{|ex| ex.haml_writer.path.match /_partial/ }.last
      assert partial_extractor.yaml_tool.yaml_hash["en"]["view2"]["partial"], "partial filenames in yaml are w/out leading _"
    end

  end
end
