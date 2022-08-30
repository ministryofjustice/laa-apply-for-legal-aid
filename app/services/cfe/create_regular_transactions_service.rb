module CFE
  class CreateRegularTransactionsService < BaseService
    def cfe_url_path
      "/assessments/#{@submission.assessment_id}/regular_transactions"
    end

    def request_body
      {
        regular_transactions: build_regular_transactions,
      }.to_json
    end

  private

    def process_response
      submission.in_progress!
    end

    def regular_transactions
      @regular_transactions ||= legal_aid_application.regular_transactions
    end

    def build_regular_transactions
      regular_transactions.each_with_object([]) do |regular_transaction, payload|
        payload << {
          category: regular_transaction.transaction_type.name,
          operation: regular_transaction.transaction_type.operation,
          amount: regular_transaction.amount.to_f,
          frequency: regular_transaction.frequency,
        }
      end
    end
  end
end
