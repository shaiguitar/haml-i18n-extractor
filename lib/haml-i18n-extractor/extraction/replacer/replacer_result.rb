module Haml
  module I18n
    class Extractor
      class ReplacerResult

        attr_accessor :modified_line, :t_name, :replaced_text, :should_be_replaced, :path

        def initialize(modified_line, t_name, replaced_text, should_be_replaced, path)
          @modified_line = modified_line
          @t_name = t_name
          @replaced_text = replaced_text
          @should_be_replaced = should_be_replaced
          @path = path
        end

        def info
          { :modified_line => @modified_line, :t_name => @t_name, :replaced_text => @replaced_text, :path => @path}
        end
      end

    end
  end
end

