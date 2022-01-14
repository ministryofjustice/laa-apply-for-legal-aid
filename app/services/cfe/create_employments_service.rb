module CFE
  class CreateDependantsService < BaseService
    delegate :legal_aid_application, to: :submission

    def cfe_url_path
      "/assessments/#{@submission.assessment_id}/dependants"
    end

    def request_body
      {
        employment_income: employment_income_data
      }.to_json
    end

    private

    def employment_income_summary
      @employment_income_summary || HMRC::ParsedResponse::EmploymentIncomeSummary.new(legal_aid_application)
    end

    def employments
      employment_income_summary.employments
    end

    def employment_income_data
      data = []
      employments.each_with_index { |employment, index| data << employment_data(employment, index + 1) }
      data
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
  end
end
