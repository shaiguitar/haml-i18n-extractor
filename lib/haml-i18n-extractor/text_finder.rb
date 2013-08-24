require 'haml'
require 'haml/parser'
require 'treetop'

module Haml
  module I18n
    class Extractor
      class TextFinder

        THINGS_THAT_ARE_NOT_POTENTIAL_TEXT = [ Haml::Parser::DIV_CLASS, Haml::Parser::DIV_ID,
            Haml::Parser::COMMENT, Haml::Parser::SANITIZE, Haml::Parser::FLAT_SCRIPT,
            Haml::Parser::FILTER, Haml::Parser::DOCTYPE, Haml::Parser::ESCAPE ]

        ## hint: Use http://rubular.com
        SIMPLE_STRING_REGEX = /["'](.*)["']/
        # = "yes"
        # = 'yes'
        LINK_TO_REGEX = /link_to\s*\(?\s*['"](.*)['"]\s*,\s*(.*)\)?/
        # = link_to "yes", "http://bla.com"
        # = link_to('yes'    , "http://bla.com")
        # = link_to(  "yes's w space", "http://bla.com")
        ELEMENT_REGEX = /%([\w.#-]+)({.+?})?(=)?(.*)/
        # %foo.bar yes
        # %foo.bar= no
        # %foo{:a => 'b'} yes
        # rubular.com against %foo#bar#cheez{:cheeze => 'hell'}= "what #{var}"

        def initialize(haml)
          @haml = haml
          @parser = Haml::Parser.new(haml, Haml::Options.new)
          Treetop.load "lib/haml-i18n-extractor/parsers/haml_i18n_extractor"
          @t_parser = HamlI18nExtractorParser.new
        end

        def line
          if @haml == ""
            return Haml::Parser::Line.new("", "", "", 0, @parser, false)
          end

          match = @haml.rstrip.scan(/(([ \t]+)?(.*?))(?:\Z|\r\n|\r|\n)/m)
          match.pop
          haml_line ||= match.each_with_index.map do |(full, whitespace, text), index|
            Haml::Parser::Line.new(whitespace, text.rstrip, full, index, @parser, false)
          end.first
          haml_line
        end

        def find
          text_match = process_by_treetop.last
        end

        # returns [ line_type, text_found ]
        def process_by_treetop
          case line.full[0]
          when *THINGS_THAT_ARE_NOT_POTENTIAL_TEXT
            [:not_text, ""]
          when Haml::Parser::SILENT_SCRIPT, Haml::Parser::ELEMENT, Haml::Parser::SCRIPT
            treetop_result = @t_parser.parse(line.full)
            # :silent, :loud, :element
            [ haml_type_map[treetop_result.haml_type.text_value], treetop_result.silent ]
          else
            [:text, line.full.strip]
          end
        end

        private

        def haml_type_map
          {
            Haml::Parser::SILENT_SCRIPT => :silent,
            Haml::Parser::ELEMENT=> :element,
            Haml::Parser::SCRIPT => :loud
          }
        end

      end
    end
  end
end
