module CFE
  class CreateStateBenefitsService < BaseService
    def cfe_url_path
      "/assessments/#{@submission.assessment_id}/state_benefit"
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
      raise CFE::SubmissionError, 'Benefit transaction cannot be identified' if bank_transactions.keys.map { |n| n.match?(/Unknown code/) }.any?

      bank_transactions.each do |name, array|
        type_hash = { "name": name, "payments": transactions(array) }
        result << type_hash
      end
      result
    end

    def transactions(array)
      result = []
      array.each do |transaction|
        result << { date: transaction.happened_at.strftime('%Y-%m-%d'), amount: transaction.amount.to_f }
      end
      result
    end

    def bank_transactions
      @bank_transactions ||= legal_aid_application.bank_transactions.for_type(:benefits).group_by(&:meta_data)
    end
  end
end
