require 'test_helper'

module Haml
  # really should just be part of integration_test.rb , testing shit from the orchestration class
  class ExtractorTest < MiniTest::Unit::TestCase

    def setup
      @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"))
    end

    def test_it_can_process_the_haml_and_replace_it_with_other_text
      @ex1.run
    end

    def test_it_should_be_able_to_process_filters_with_the_haml_parser_now
      #@FIXME
      #raise 'implment me...check the finder#filters method and make sure you process the whole file at once so the parser gets it...'
    end

    def test_with_a_type_of_overwrite_or_dump_affecting_haml_writer
      h = Haml::I18n::Extractor.new(file_path("ex1.haml"), :type => :overwrite)
      assert_equal h.haml_writer.overwrite?, true
      h = Haml::I18n::Extractor.new(file_path("ex1.haml"))
      assert_equal h.haml_writer.overwrite?, false
    end

    def test_with_a_interactive_option_which_prompts_the_userper_line
      h = Haml::I18n::Extractor.new(file_path("ex1.haml"), :interactive => true)
      assert_equal h.interactive?, true
      h = Haml::I18n::Extractor.new(file_path("ex1.haml"))
      assert_equal h.interactive?, false
    end

    def test_with_a_interactive_option_takes_user_input_into_consideration_for_haml
      h = Haml::I18n::Extractor.new(file_path("ex1.haml"), :interactive => true)
      user_input = "D" # dump
      File.readlines(file_path("ex1.haml")).size.times do
        user_input << "n" # do not replace lines
      end
      with_highline(user_input) do
        h.run
      end
      # no changes were made cause user was all like 'uhhh, no thxk'
      assert_equal File.read(h.haml_writer.path), File.read(file_path("ex1.haml"))
    end

    def test_with_a_interactive_option_takes_user_input_n_as_next_and_stops_processing_file
      h = Haml::I18n::Extractor.new(file_path("ex1.haml"), :interactive => true)
      user_input = "D" # dump
      File.readlines(file_path("ex1.haml")).size.times do
        user_input << "N" # just move on to next file
      end
      with_highline(user_input) do
        h.run
      end
      # no changes were made cause user was all like 'uhhh, move to next file'
      assert_equal File.read(h.haml_writer.path), File.read(file_path("ex1.haml"))
    end

    def test_with_a_interactive_option_takes_user_input_into_consideration_for_yaml
      TestHelper.hax_shit
      h = Haml::I18n::Extractor.new(file_path("ex1.haml"), :interactive => true)
      user_input = "D" # dump
      File.readlines(file_path("ex1.haml")).size.times do
        user_input << "n" # do not replace lines
      end
      with_highline(user_input) do
        h.run
      end
      # no changes were made cause user was all like 'uhhh, no thxk'
      assert_equal YAML.load(File.read(h.yaml_writer.yaml_file)), {}
    end

    def test_with_a_interactive_option_user_can_tag_a_line_for_later_review
      TestHelper.hax_shit
      if File.exist?(Haml::I18n::Extractor::TaggingWriter::DB)
        assert_equal File.readlines(Haml::I18n::Extractor::TaggingWriter::DB), []
      end
      h = Haml::I18n::Extractor.new(file_path("ex1.haml"), :interactive => true)
      user_input = "D" # dump
      File.readlines(file_path("ex1.haml")).size.times do
        user_input << "t" # tag the lines
      end
      with_highline(user_input) do
        h.run
      end
      assert (File.readlines(Haml::I18n::Extractor::TaggingWriter::DB).size != 0), "tag lines get added to file"
    end


    def test_can_not_initialize_if_the_haml_is_not_valid_syntax
      begin
        Haml::I18n::Extractor.new(file_path("bad.haml"))
        assert false, "should not get here"
      rescue Haml::I18n::Extractor::InvalidSyntax
        assert true, "it should fail with invalid syntax"
      end
    end

    def test_it_writes_the_haml_to_an_out_file_if_valid_haml_output
      FileUtils.rm_rf(@ex1.haml_writer.path)
      assert_equal File.exists?(@ex1.haml_writer.path), false
      @ex1.run
      assert_equal File.exists?(@ex1.haml_writer.path), true
    end

    def test_it_writes_the_locale_info_to_an_out_file_when_run
      TestHelper.hax_shit
      assert_equal File.exists?(@ex1.yaml_writer.yaml_file), false
      @ex1.run
      assert_equal File.exists?(@ex1.yaml_writer.yaml_file), true
      assert_equal YAML.load(File.read(@ex1.yaml_writer.yaml_file)), @ex1.yaml_writer.yaml_hash
    end

    def test_sends_a_hash_over_of_replacement_info_to_its_yaml_writer_when_run
      @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"))
      assert_equal @ex1.yaml_writer.info_for_yaml, nil
      @ex1.run
      assert @ex1.yaml_writer.info_for_yaml.is_a?(Hash), "its is hash of info about the files lines"
      assert_equal @ex1.yaml_writer.info_for_yaml.size, @ex1.haml_reader.lines.size
    end

    def test_it_fails_before_it_writes_to_an_out_file_if_it_is_not_valid
      begin
        @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"))
        @ex1.stub(:assign_new_body, nil) do #nop
          @ex1.haml_writer.body = File.read(file_path("bad.haml"))
          @ex1.run
        end
        assert false, "should raise"
      rescue Haml::I18n::Extractor::InvalidSyntax
        assert true, "it should not allow invalid output to be written"
      end
    end
    
  end
end
