module CFE
  class CreateIrregularIncomesService < BaseService
    delegate :legal_aid_application, to: :submission
    delegate :irregular_incomes, to: :legal_aid_application

    def cfe_url_path
      "/assessments/#{@submission.assessment_id}/irregular_incomes"
    end

    def request_body
      {
        payments: irregular_incomes.map(&:as_json)
      }.to_json
    end

    def process_response
      @submission.irregular_income_created!
    end
  end
end
