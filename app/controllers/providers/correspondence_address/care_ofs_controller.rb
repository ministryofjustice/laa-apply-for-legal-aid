module Providers
  module CorrespondenceAddress
    class CareOfsController < ProviderBaseController
      prefix_step_with :correspondence_address

      def show
        @form = Addresses::CareOfForm.new(model: address)
      end

      def update
        @form = Addresses::CareOfForm.new(form_params)

        delete_care_of_information if form_params[:care_of].eql?("no")

        render :show unless save_continue_or_draft(@form)
      end

    private

      def delete_care_of_information
        address.care_of_first_name = ""
        address.care_of_last_name = ""
        address.care_of_organisation_name = ""
        address.save!
      end

      def address
        @address ||= legal_aid_application.applicant.address
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
