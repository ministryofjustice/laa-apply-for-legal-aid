module Providers
  module ApplicationMeritsTask
    class CourtOrderCopiesController < ProviderBaseController
      def show
        @form = ApplicationMeritsTask::PLFCourtOrderForm.new(model: legal_aid_application)
        @display_banner = plf_court_order_attached?
      end

      def update
        @form = ApplicationMeritsTask::PLFCourtOrderForm.new(form_params)

        if plf_court_order_attached? && @form.plf_court_order.eql?("false")
          plf_court_order_evidence.delete
          plf_court_order_pdf.delete if plf_court_order_pdf.present?
        end

        render :show unless update_task_save_continue_or_draft(:application, :court_order_copy)
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
        legal_aid_application.attachments.find { |attachment| attachment[:attachment_type] == "plf_court_order" }
      end

      def plf_court_order_pdf
        legal_aid_application.attachments.find { |attachment| attachment[:attachment_type] == "plf_court_order_pdf" }
      end
    end
  end
end
