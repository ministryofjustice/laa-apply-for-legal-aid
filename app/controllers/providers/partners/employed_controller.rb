module Providers
  module Partners
    class EmployedController < ProviderBaseController
      prefix_step_with :partner

      def index
        @partner = partner
        @legal_aid_application.reset_from_use_ccms! if @legal_aid_application.use_ccms?
        @form = ::Partners::EmployedForm.new(model: partner)
        legal_aid_application.assess_partner_means!
      end

      def create
        @form = ::Partners::EmployedForm.new(form_params)
        render :index unless save_continue_or_draft(@form)
      end

    private

      def partner
        legal_aid_application.partner || legal_aid_application.build_partner
      end

      def form_params
        merge_with_model(partner) do
          next {} unless params[:partner]

          params.require(:partner).permit(:employed, :self_employed, :armed_forces, :none_selected)
        end
      end
    end
  end
end
