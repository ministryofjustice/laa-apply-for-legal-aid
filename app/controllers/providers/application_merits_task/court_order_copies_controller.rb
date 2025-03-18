module Providers
  module ApplicationMeritsTask
    class CourtOrderCopiesController < ProviderBaseController
      include DeleteAttachments

      def show
        @form = ApplicationMeritsTask::PLFCourtOrderForm.new(model: legal_aid_application)
        @display_banner = plf_court_order_attached?
      end

      def update
        @form = ApplicationMeritsTask::PLFCourtOrderForm.new(form_params)

        delete_evidence(plf_court_order_evidence) if plf_court_order_attached? && @form.plf_court_order.eql?("false")

        update_task(:application, :court_order_copy)
        return continue_or_draft if draft_selected?

        if @form.valid?
          @form.save!
          return go_forward(@form.copy_of_court_order?)
        else
          render :show
        end
      end

      def form_params
        merge_with_model(legal_aid_application) do
          return {} unless params[:legal_aid_application]

          params.expect(legal_aid_application: [:plf_court_order])
        end
      end

    private

      def plf_court_order_attached?
        plf_court_order_evidence.present?
      end

      def plf_court_order_evidence
        @plf_court_order_evidence ||= find_attachments_starting_with("plf_court_order")
      end
    end
  end
end
