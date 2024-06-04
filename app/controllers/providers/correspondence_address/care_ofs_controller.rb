module Providers
  module CorrespondenceAddress
    class CareOfsController < ProviderBaseController
      prefix_step_with :correspondence_address

      def show
        @form = Addresses::CareOfForm.new(model: address)
      end

      def update
        @form = Addresses::CareOfForm.new(form_params)

        render :show unless save_continue_or_draft(@form)
      end

    private

      def legal_aid_application
        @legal_aid_application ||= LegalAidApplication.find_by(id: params[:legal_aid_application_id])
      end
      delegate :applicant, to: :legal_aid_application

      def address
        applicant.address
      end

      def form_params
        merge_with_model(address) do
          next {} unless params[:address]

          params.require(:address).permit(:care_of, :care_of_first_name, :care_of_last_name, :care_of_organisation_name)
        end
      end
    end
  end
end
