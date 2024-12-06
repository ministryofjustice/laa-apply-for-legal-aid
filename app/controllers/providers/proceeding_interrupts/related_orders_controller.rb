module Providers
  module ProceedingInterrupts
    class RelatedOrdersController < ProviderBaseController
      # prefix_step_with :proceedings_sca

      def show
        proceeding
        @form = RelatedOrdersForm.new
      end

      def update
        @form = RelatedOrdersForm.new(form_params)
        if @form.valid?
          return redirect_to providers_legal_aid_application_sca_interrupt_path(legal_aid_application, "plf_none_selected") if form_params[:none_selected].present?

          continue_or_draft(proceeding:)
        else
          render :show
        end
      end

    private

      def proceeding
        @proceeding ||= legal_aid_application.proceedings.last
      end

      def form_params
        params
          .require(:providers_proceeding_interrupts_related_orders_form)
          .permit(:none_selected, selected_orders: [])
      end
    end
  end
end
