require 'test_helper'

module Haml
  class ExtractorTest < MiniTest::Unit::TestCase

    # TODO: read in the file, parse it line by line, use text_finder and extract away
    # TODO: ensure if there are duplicate strings on one line, to handle that correctly? not sure if that's even a use-case?
    # for eg: find_text("%a{'href' => 'http://whatever'} whatever"), ["whatever"]
    # TODO: Do extraction, verify the haml is parsable at the end.
    # TODO: handles duplicate texts and doesn't silently let that pass somehow
    # TODO: does not fail on handling text with weird characters so t() fails weirdly ("hell's a ~@~" => t(".hell's_a_~@~"))...

    def file_path(name)
      File.dirname(__FILE__) + "/support/#{name}"
    end
    
    def setup
      @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"))
    end

    test "can not initialize if the haml is not valid syntax" do
      begin
        Haml::I18n::Extractor.new(file_path("bad.haml"))
        assert false, "should not get here"
      rescue Haml::I18n::Extractor::InvalidSyntax
        assert true, "it should fail with invalid syntax"
      end
    end

    test "can initialize if the haml is valid syntax" do
      assert true, "extractor can initialize"
    end

    test "it can process the haml and replace it with other text" do
      @ex1.run!
    end
    
    test "it validates when it before it writes to an out file" do
      assert false, "TODO"
    end

    test "it fails before it writes to an out file if it is not valid" do
      #   @haml_file_out = File.open(haml_path.gsub(/.haml$/, "i18n-extractor.haml"), "w+")
      assert false, "TODO"
    end
    
  end
end