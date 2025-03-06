module Providers
  module Means
    class PropertyDetailsController < ProviderBaseController
      def show
        @form = LegalAidApplications::PropertyDetailsForm.new(model: legal_aid_application)
      end

      def update
        @form = LegalAidApplications::PropertyDetailsForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def form_params
        merge_with_model(legal_aid_application) do
          next {} unless params[:legal_aid_application]

          params.expect(legal_aid_application: [:property_value,
                                                :outstanding_mortgage_amount,
                                                :shared_ownership,
                                                :percentage_home])
        end
      end
    end
  end
end
