module V1
  module Partners
    class BankStatementsController < V1::BankStatementsController
      def initialize
        super
        @attachment_type = "partner_bank_statement_evidence"
        @attachment_type_capture = /^#{@attachment_type}_(\d+)$/
      end

    private

      # can be shared with v1 bank statement controller
      def sequenced_attachment_name
        if legal_aid_application.attachments.partner_bank_statement_evidence.any?
          most_recent_name = legal_aid_application.attachments.partner_bank_statement_evidence.order(:attachment_name).last.attachment_name
          increment_name(most_recent_name)
        else
          @attachment_type
        end
      end

      def error_path
        "providers/partners/bank_statement_form"
      end
    end
  end
end
