module Providers
  module LinkApplication
    class FindLinkApplicationsController < ProviderBaseController
      def show
        @form = Providers::LinkApplication::FindLinkApplicationForm.new(model: linked_application)
      end

      def update
        @form = Providers::LinkApplication::FindLinkApplicationForm.new(form_params)

        render :show unless save_continue_or_draft(@form)
      end

    private

      def linked_application
        legal_aid_application.lead_linked_application || legal_aid_application.build_lead_linked_application
      end

      def form_params
        merge_with_model(linked_application) do
          params.require(:linked_application).permit(:search_laa_reference)
        end
      end
    end
  end
end
