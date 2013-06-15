require 'test_helper'

module Haml
  class WorkflowTest < MiniTest::Unit::TestCase

  def setup
    TestHelper.setup_project_directory! # tests here rely on this setup...
    @workflow = Haml::I18n::Extractor::Workflow.new(TestHelper::PROJECT_DIR)
  end

  def teardown
    TestHelper.teardown_project_directory!
  end

  def full_project_user_interaction
    automate_user_interaction = ""
    6.times do                            # should be number of files we're testing on
      automate_user_interaction << "O"    # overwrite file
      50.times do                         # should be number of lines in file,
                                          # this should do right now.
        automate_user_interaction << "y"  # replace line
      end
    end
    automate_user_interaction
 end

  def test_it_should_work_on_a_directory_mkay
    filename = "#{TestHelper::PROJECT_DIR}app/views/bar/thang.haml"
    bad_worfklow = Haml::I18n::Extractor::Workflow.new(filename)
    assert false, "should raise"
    rescue Haml::I18n::Extractor::NotADirectory
      assert true, "workflow works on a directory bubba."
  end

  def test_it_finds_all_haml_files
    assert_equal @workflow.files.size, 4
  end

  def test_outputs_stats
    with_highline do
      @workflow.start_message
      assert @output.string.match(/Found 4 haml files/), "Outputs stats"
    end
  end

  def test_yaml_file_in_config
    with_highline(full_project_user_interaction) do
      @workflow.run
    end
  end

  def test_run_works
    with_highline(full_project_user_interaction) do
      @workflow.run
    end
  end

  end
end
