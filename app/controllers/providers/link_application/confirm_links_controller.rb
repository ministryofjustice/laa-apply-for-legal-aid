module Providers
  module LinkApplication
    class ConfirmLinksController < ProviderBaseController
      prefix_step_with :link_application

      def show
        all_linked_applications
        @form = Providers::LinkApplication::ConfirmLinkForm.new(model: linked_application)
      end

    private

      def linked_application
        legal_aid_application.lead_linked_application || legal_aid_application.build_lead_linked_application
      end

      def all_linked_applications
        @all_linked_applications = legal_aid_application.lead_application&.associated_applications&.where&.not(id: legal_aid_application.id)
      end
    end
  end
end
