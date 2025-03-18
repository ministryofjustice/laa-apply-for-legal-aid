module Providers
  module ApplicationMeritsTask
    class CourtOrderCopiesController < ProviderBaseController
      def show
        @form = ApplicationMeritsTask::PLFCourtOrderForm.new(model: legal_aid_application)
      end

      def update
        @form = ApplicationMeritsTask::PLFCourtOrderForm.new(form_params)

        update_task(:application, :court_order_copy)
        return continue_or_draft if draft_selected?

        if @form.valid?
          @form.save!
          return go_forward(@form.copy_of_court_order?)
        end

        render :show
      end

      def form_params
        merge_with_model(legal_aid_application) do
          return {} unless params[:legal_aid_application]

          params.expect(legal_aid_application: [:plf_court_order])
        end
      end
    end
  end
end
