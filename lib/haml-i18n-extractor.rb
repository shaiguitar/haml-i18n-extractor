require "trollop"

require "haml-i18n-extractor/version"

require "haml-i18n-extractor/extraction/text_finder"
require "haml-i18n-extractor/extraction/exception_finder"
require "haml-i18n-extractor/extraction/haml_parser"
require "haml-i18n-extractor/extraction/haml_reader"
require "haml-i18n-extractor/extraction/tagging_tool"
require "haml-i18n-extractor/extraction/text_replacer"
require "haml-i18n-extractor/extraction/haml_writer"
require "haml-i18n-extractor/extraction/yaml_tool"
require "haml-i18n-extractor/extraction/extractor"

require "haml-i18n-extractor/flow/helpers"
require "haml-i18n-extractor/flow/prompter"
require "haml-i18n-extractor/flow/user_action"
require "haml-i18n-extractor/flow/workflow"
require "haml-i18n-extractor/flow/cli"
