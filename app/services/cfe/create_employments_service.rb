module CFE
  class CreateEmploymentsService < BaseService
    delegate :legal_aid_application, to: :submission

    def cfe_url_path
      "/assessments/#{@submission.assessment_id}/employments"
    end

    def request_body
      {
        employment_income: employment_income_payload
      }.to_json
    end

    def process_response
      @submission.employments_created!
    end

    private

    def employment_income_payload
      payload = []
      return payload unless legal_aid_application.hmrc_employment_income?

      employments.each_with_index { |employment, index| payload << employment_data(employment, index + 1) }
      payload
    end

    def employment_data(employment, job_num)
      {
        name: "Job #{job_num}",
        payments: employment_payments(employment)
      }
    end

    def employment_payments(employment)
      data = []
      employment.payments.each { |payment| data << individual_payment_data(payment) }
      data
    end

    def individual_payment_data(payment)
      {
        date: payment.formatted_payment_date,
        gross: payment.gross_pay,
        benefits_in_kind: payment.benefits_in_kind,
        tax: payment.tax,
        national_insurance: payment.national_insurance,
        net_employment_income: payment.net_pay
      }
    end

    def employments
      employment_income_summary.employments
    end

    def employment_income_summary
      @employment_income_summary || HMRC::ParsedResponse::EmploymentIncomeSummary.new(legal_aid_application)
    end
  end
end
