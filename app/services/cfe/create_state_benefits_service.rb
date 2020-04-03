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

    def build_transactions
      result = []
      benefit_types = legal_aid_application.bank_transactions.for_type(:benefits).pluck(:meta_data).uniq

      raise CFE::SubmissionError, 'Benefit transactions un-coded' if benefit_types.any?(nil)
      raise CFE::SubmissionError, 'Benefit transaction cannot be identified' if benefit_types.map { |n| n.match?(/Unknown code/) }.any?

      benefit_types.each do |type|
        type_hash = { "name": type, "payments": transactions(type) }
        result << type_hash
      end
      result
    end

    def transactions(type)
      result = []
      legal_aid_application.bank_transactions.for_type(:benefits).where(meta_data: type).each do |transaction|
        result << { date: transaction.happened_at.strftime('%Y-%m-%d'), amount: transaction.amount.to_f }
      end
      result
    end
  end
end
