module Capybara
  module RequestHelpers
    def self.included(base)
      super
      base.include(ContentHelpers)
    end

    module ContentHelpers
      def have_error_message(text)
        have_css(".govuk-error-summary__list > li", text:)
      end
    end
  end
end
