module CFE
  class CreateOtherIncomeService < BaseService

    def cfe_url_path
      "/assessments/#{@submission.assessment_id}/other_income"
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
      transactions_of_interest_grouped_by_transaction_type.each do |transaction_type, transactions|
        array << all_transactions_of_one_type(transaction_type, transactions)
      end
      array
    end

    def all_transactions_of_one_type(transaction_type, transactions)
      {
        source: transaction_type.name,
        payments: transactions.map { |t| single_transaction_hash(t) }
      }
    end

    def single_transaction_hash(transaction)
      {
        date: transaction.happened_at.strftime('%Y-%m-%d'),
        amount: transaction.amount.to_f
      }
    end

    def transactions_of_interest_grouped_by_transaction_type
      legal_aid_application
        .bank_transactions
        .credit
        .where(transaction_type_id: other_income_transaction_type_ids)
        .group_by(&:transaction_type)
    end

    def other_income_transaction_type_ids
      TransactionType.other_income.pluck(:id)
    end


  end
end
