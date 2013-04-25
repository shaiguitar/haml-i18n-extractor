module Haml
  module I18n
    class Extractor
      module Helpers
        module Highline

          def highlight(str, color = :yellow)
            "<%= color('#{str.to_s}', :black, :on_#{color}) %>"
          end

        end
      end
    end
  end
end

