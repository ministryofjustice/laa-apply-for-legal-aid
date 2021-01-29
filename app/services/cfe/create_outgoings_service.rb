module CFE
  class CreateOutgoingsService < BaseService
    def cfe_url_path
      "/assessments/#{@submission.assessment_id}/outgoings"
    end

    def request_body
      {
        outgoings: build_transactions
      }.to_json
    end

    private

    def process_response
      @submission.outgoings_created!
    end

    def build_transactions
      result = []

      bank_transactions.each do |transaction_type_id, array|
        name = TransactionType.find(transaction_type_id).name
        type_hash = { name: name, payments: transactions(array) }
        result << type_hash
      end
      result
    end

    def transactions(array)
      result = []
      array.each do |transaction|
        result << {
          payment_date: transaction.happened_at.strftime('%Y-%m-%d'),
          amount: transaction.amount.abs.to_f,
          client_id: transaction.id
        }
      end
      result
    end

    def bank_transactions
      @bank_transactions ||= legal_aid_application
                             .bank_transactions
                             .debit
                             .where.not(transaction_type_id: nil)
                             .order(:happened_at)
                             .group_by(&:transaction_type_id)
    end
  end
end
