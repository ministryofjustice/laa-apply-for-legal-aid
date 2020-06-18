module Reports
  class BankTransactionReportCreator < BaseReportCreator
    def call
      return if legal_aid_application.bank_transaction_report

      attachment = legal_aid_application.attachments.create!(attachment_type: 'bank_transaction_report',
                                                             attachment_name: 'bank_transaction_report.csv')

      attachment.document.attach(
        io: StringIO.new(generate_csv),
        filename: 'bank_transaction_report.csv',
        content_type: 'text/csv'
      )
    end

    private

    def generate_csv
      ensure_case_ccms_reference_exists
      csv_string = CSV.generate do |csv|
        csv << BankTransactionPresenter.headers
        transactions.each do |transaction|
          remarks = transaction_remarks_for[transaction.id]&.reasons.to_a
          csv << BankTransactionPresenter.present!(transaction, remarks)
        end
      end
      csv_string
    end

    def transactions
      legal_aid_application.bank_transactions.order(happened_at: :asc)
    end

    def transaction_remarks_for
      @transaction_remarks_for ||= legal_aid_application.cfe_result.remarks.review_transactions.transactions
    end
  end
end
