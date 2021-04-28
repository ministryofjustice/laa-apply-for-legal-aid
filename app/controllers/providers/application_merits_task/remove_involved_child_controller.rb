module Providers
  module ApplicationMeritsTask
    class RemoveInvolvedChildController < ProviderBaseController
      def show
        form
        involved_child
      end

      def update
        if form.valid?
          involved_child&.destroy! if form.remove_involved_child?
          return go_forward
        end

        involved_child
        render :show
      end

      private

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :remove_involved_child,
          form_params: form_params
        )
      end

      def involved_child
        @involved_child ||= legal_aid_application.involved_children.find(params[:id])
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.require(:binary_choice_form).permit(:remove_involved_child)
      end
    end
  end
end
