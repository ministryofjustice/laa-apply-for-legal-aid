module CFE
  class CreateOtherIncomeService < BaseService
    def cfe_url_path
      "/assessments/#{@submission.assessment_id}/other_incomes"
    end

    def request_body
      {
        other_incomes: other_income_data
      }.to_json
    end

    private

    def process_response
      @submission.other_income_created!
    end

    def other_income_data
      array = []
      transaction_types = grouped_transactions.keys.sort_by(&:name)
      transaction_types.each do |transaction_type|
        array << all_transactions_of_one_type(transaction_type, grouped_transactions[transaction_type])
      end
      array
    end

    def all_transactions_of_one_type(transaction_type, transactions)
      {
        source: transaction_type.name.humanize,
        payments: transactions.map { |t| single_transaction_hash(t) }
      }
    end

    def single_transaction_hash(transaction)
      {
        date: transaction.happened_at.strftime('%Y-%m-%d'),
        amount: transaction.amount.to_f,
        client_id: transaction.id
      }
    end

    def grouped_transactions
      @grouped_transactions ||= legal_aid_application
                                .bank_transactions
                                .credit
                                .where(transaction_type_id: other_income_transaction_type_ids)
                                .order(:happened_at)
                                .group_by(&:transaction_type)
    end

    def other_income_transaction_type_ids
      TransactionType.other_income.pluck(:id)
    end
  end
end
