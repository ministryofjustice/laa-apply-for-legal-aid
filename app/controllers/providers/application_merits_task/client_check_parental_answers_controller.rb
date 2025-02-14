module Providers
  module ApplicationMeritsTask
    class ClientCheckParentalAnswersController < ProviderBaseController
      prefix_step_with :application_merits_task
      def show
        legal_aid_application.rejected_all_parental_responsibilities!
        @relationship_to_children = applicant.relationship_to_children
      end

      def update
        legal_aid_application.provider_enter_merits!
        continue_or_draft
      end

    private

      def applicant
        legal_aid_application.applicant
      end
    end
  end
end
