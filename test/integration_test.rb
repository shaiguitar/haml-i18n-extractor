module Haml
  class IntegrationTest < MiniTest::Unit::TestCase

    def setup
      TestHelper.setup_project_directory!
    end

    def teardown
      TestHelper.teardown_project_directory!
    end

    test "it can handle namespaced views" do
      workflow = TestHelper.mock_full_project_user_interaction!
      namespaced_extractor = workflow.extractors.select{|ex| ex.haml_writer.path.match /namespace/ }.last
      assert namespaced_extractor.yaml_tool.yaml_hash["en"]["namespace"], "namespace key works"
    end

  end
end
