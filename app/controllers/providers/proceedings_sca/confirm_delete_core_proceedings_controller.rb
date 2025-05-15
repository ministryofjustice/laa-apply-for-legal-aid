module Providers
  module ProceedingsSCA
    class ConfirmDeleteCoreProceedingsController < ProviderBaseController
      prefix_step_with :proceedings_sca

      def show
        proceeding
      end

      def destroy
        remove_proceedings
        replace_last_page_in_history(home_path)

        return redirect_to providers_legal_aid_application_proceedings_types_path if proceedings.empty?

        redirect_to providers_legal_aid_application_has_other_proceedings_path
      end

    private

      def proceedings
        @proceedings ||= legal_aid_application.proceedings
      end

      def proceeding
        @proceeding = Proceeding.find(params["proceeding_id"])
      end

      def related_proceedings
        @related_proceedings ||= legal_aid_application.related_proceedings
      end

      def remove_proceedings
        LegalFramework::RemoveProceedingService.call(legal_aid_application, proceeding)
        related_proceedings.each do |proceeding|
          LegalFramework::RemoveProceedingService.call(legal_aid_application, proceeding)
        end
        LegalFramework::LeadProceedingAssignmentService.call(legal_aid_application)
      end
    end
  end
end
