module CFE
  class CreateStateBenefitsService < BaseService
    def cfe_url_path
      "/assessments/#{@submission.assessment_id}/state_benefits"
    end

    def request_body
      {
        "state_benefits": build_transactions
      }.to_json
    end

    private

    def process_response
      @submission.state_benefits_created!
    end

    def build_transactions
      result = []

      raise CFE::SubmissionError, 'Benefit transactions un-coded' if bank_transactions.keys.any?(nil)

      bank_transactions.each do |meta_data, array|
        type_hash = { name: meta_data[:name], "payments": transactions(array) }
        result << type_hash
      end
      result
    end

    def transactions(array)
      result = []
      array.each do |transaction|
        result << {
          date: transaction.happened_at.strftime('%Y-%m-%d'),
          amount: transaction.amount.to_f,
          client_id: transaction.id
        }
      end
      result
    end

    def bank_transactions
      @bank_transactions ||= legal_aid_application
                             .bank_transactions
                             .for_type(:benefits)
                             .order(:happened_at)
                             .group_by(&:meta_data)
    end
  end
end
