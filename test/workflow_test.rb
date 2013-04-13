require 'test_helper'

module Haml
  class WorkflowTest < MiniTest::Unit::TestCase

  def setup
    TestHelper.setup_project_directory! # tests here rely on this setup...
    @workflow = Haml::I18n::Extractor::Workflow.new(TestHelper::PROJECT_DIR)
  end

  def with_highline(input = nil, &blk)
    old_terminal = $terminal
    @input     = input ? StringIO.new(input) : StringIO.new
    @output    = StringIO.new
    $terminal = HighLine.new(@input, @output)
    yield
  ensure
    $terminal = old_terminal
  end
  
  def teardown
    TestHelper.teardown_project_directory!
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
      @workflow.output_stats
      assert @output.string.match(/Found 4 files/), "Outputs stats"
    end
  end
  
  def test_asks_to_process_file_yes
    with_highline("o") do
      assert_equal @workflow.process_file?(@workflow.files.first), :overwrite
      assert @output.string.match(/Process file #{@workflow.files.first}?/), "o to overwriting the file"
    end
  end      

  def test_asks_to_process_file_no
    with_highline("n") do
      assert_equal @workflow.process_file?(@workflow.files.first), nil
      assert @output.string.match(/Process file #{@workflow.files.first}?/), "n for next file"
    end
  end
  
  def test_asks_to_process_file_dump
    with_highline("d") do
      assert_equal @workflow.process_file?(@workflow.files.first), :dump
      assert @output.string.match(/Process file #{@workflow.files.first}?/), "d for dumping the file"
    end
  end
                       
  def test_run_works
    with_highline("odnd") do
      @workflow.run
    end
  end

  end
end
