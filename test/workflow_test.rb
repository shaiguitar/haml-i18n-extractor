require 'test_helper'

module Haml
  class WorkflowTest < MiniTest::Unit::TestCase

    def setup
      TestHelper.setup_project_directory! # tests here rely on this setup...
      @workflow = TestHelper.mock_full_project_user_interaction! 
    end

    def teardown
      TestHelper.teardown_project_directory!
    end

    test "it_should_work_on_a_directory_mkay" do
      begin
        filename = "#{TestHelper::PROJECT_DIR}app/views/bar/thang.haml"
        bad_worfklow = Haml::I18n::Extractor::Workflow.new(filename)
        assert false, "should raise"
      rescue Haml::I18n::Extractor::NotADirectory
        assert true, "workflow works on a directory bubba."
      end
    end

    test "it_finds_all_haml_files" do
      assert_equal @workflow.files.size, 6
    end

    test "outputs_stats" do
      with_highline do
        @workflow.start_message
        assert @output.string.match(/Found 6 haml files/), "Outputs stats"
      end
    end

    test "yaml_file_in_config" do
      TestHelper.mock_full_project_user_interaction!
    end

  end
end
