module Providers
  module DWP
    class ResultsController < ProviderBaseController
      prefix_step_with :dwp

      include ApplicantDetailsCheckable
      include BenefitCheckSkippable

      # OPTIMIZE: This will call check_benefits twice (on show and update). Is this neccessary? I cannot see why! JS
      before_action :check_benefits, :benefit_check_status

      def show
        @override_path = if legal_aid_application.partner
                           providers_legal_aid_application_dwp_partner_override_path
                         else
                           providers_legal_aid_application_check_client_details_path
                         end
      end

      def update
        # If this action is invoked then the "Yes, continue" has been pressed (i.e. they have accepted the DWP result)
        # In this case we can simply go forward but should mark the applicants details as having been checked in case
        # they have have gotten to this page via a Back clik or backpage following a "This is not correct"
        #
        # ps: if they have clicked "This is not correct" see the check client details controller
        details_checked! unless details_checked?
        go_forward
      end

    private

      def check_benefits
        legal_aid_application.add_benefit_check_result unless !Setting.collect_dwp_data? || skip_because_of_short_last_name
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
