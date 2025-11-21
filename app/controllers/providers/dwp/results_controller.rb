module Providers
  module DWP
    class ResultsController < ProviderBaseController
      prefix_step_with :dwp

      include ApplicantDetailsCheckable
      include BenefitCheckSkippable
      include DWPOutcomeHelper

      before_action :check_benefits, :benefit_check_status, only: :show

      def show
        details_checked! unless details_checked?
        reset_confirm_dwp_status!(legal_aid_application)

        HMRC::CreateResponsesService.call(legal_aid_application) if make_hmrc_call?

        # set the path for the "This is not correct" link flow
        @override_path = if legal_aid_application.partner
                           providers_legal_aid_application_dwp_partner_override_path
                         else
                           providers_legal_aid_application_check_client_details_path
                         end
      end

      # If this action is invoked then the "Yes, continue" has been pressed (i.e. they have accepted the DWP result)
      # In this case we can simply go forward.
      #
      # ps: if they have clicked "This is not correct" see the override path set in show action
      def update
        confirm_dwp_status_correct!(legal_aid_application)
        go_forward
      end

    private

      def check_benefits
        return unless legal_aid_application.benefit_check_result_needs_updating? && Setting.collect_dwp_data?

        legal_aid_application.upsert_benefit_check_result unless skip_because_of_short_last_name
      end

      def skip_because_of_short_last_name
        mark_as_benefit_check_skipped!("short_name") if short_last_name?
      end

      def short_last_name?
        applicant.last_name.length == 1
      end

      def benefit_check_status
        @benefit_check_status ||= legal_aid_application.benefit_check_status
      end
    end
  end
end
