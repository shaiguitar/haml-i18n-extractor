if defined?(Encoding)
  Encoding.default_internal = Encoding::UTF_8 if Encoding.respond_to?(:default_internal)
  Encoding.default_external = Encoding::UTF_8 if Encoding.respond_to?(:default_external)
end

require "trollop"

require "haml-i18n-extractor/version"
require "haml-i18n-extractor/helpers"

require "haml-i18n-extractor/extraction/finder/text_finder"
require "haml-i18n-extractor/extraction/finder/exception_finder"
require "haml-i18n-extractor/extraction/replacer/text_replacer"
require "haml-i18n-extractor/extraction/replacer/replacer_result"
require "haml-i18n-extractor/extraction/replacer/interpolation_helper"

require "haml-i18n-extractor/extraction/haml_parser"
require "haml-i18n-extractor/extraction/haml_reader"
require "haml-i18n-extractor/extraction/tagging_writer"
require "haml-i18n-extractor/extraction/haml_writer"
require "haml-i18n-extractor/extraction/yaml_writer"
require "haml-i18n-extractor/extraction/extractor"


require "haml-i18n-extractor/flow/prompter"
require "haml-i18n-extractor/flow/user_action"
require "haml-i18n-extractor/flow/workflow"
require "haml-i18n-extractor/flow/cli"
