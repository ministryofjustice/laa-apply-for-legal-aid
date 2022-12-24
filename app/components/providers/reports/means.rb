module Providers
  module Reports
    class Means < ViewComponent::Base
      # rubocop:disable Lint/MissingSuper
      def initialize(legal_aid_application:, manual_review_determiner:)
        @legal_aid_application = legal_aid_application
        @cfe_result = legal_aid_application.cfe_result
        @manual_review_determiner = manual_review_determiner
      end
      # rubocop:enable Lint/MissingSuper
    end
  end
end
