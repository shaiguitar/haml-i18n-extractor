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

    def test_it_should_work_on_a_directory_mkay
      begin
        filename = "#{TestHelper::PROJECT_DIR}app/views/bar/thang.haml"
        bad_worfklow = Haml::I18n::Extractor::Workflow.new(filename)
        assert false, "should raise"
      rescue Haml::I18n::Extractor::NotADirectory
        assert true, "workflow works on a directory bubba."
      end
    end

    def test_it_finds_all_haml_files
      assert_equal @workflow.files.size, 9
    end

    def test_outputs_stats
      with_highline do
        @workflow.start_message
        assert @output.string.match(/Found \d haml files/), "Outputs stats"
      end
    end

    def test_yaml_file_in_config
      TestHelper.mock_full_project_user_interaction!
    end

  end
end
