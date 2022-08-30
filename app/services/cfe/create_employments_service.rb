module CFE
  class CreateEmploymentsService < BaseService
    delegate :legal_aid_application, to: :submission

    def cfe_url_path
      "/assessments/#{@submission.assessment_id}/employments"
    end

    def request_body
      { employment_income: employment_income_payload }.to_json
    end

    def process_response
      @submission.in_progress!
    end

  private

    def employment_income_payload
      payload = []
      return payload unless legal_aid_application.hmrc_employment_income?

      employments.each_with_index { |employment, index| payload << employment_data(employment, index + 1) }
      payload
    end

    def employment_data(employment, _job_num)
      {
        name: employment.name,
        client_id: employment.id,
        payments: employment_payments(employment),
      }
    end

    def employment_payments(employment)
      data = []
      employment.employment_payments.each do |payment|
        data << individual_payment_data(payment)
      end
      data
    end

    def individual_payment_data(payment)
      # convert the values to floats here to prevent them from being quoted by JSON
      {
        client_id: payment.id,
        date: payment.date.strftime("%F"),
        gross: payment.gross.to_f,
        benefits_in_kind: payment.benefits_in_kind.to_f,
        tax: payment.tax.to_f,
        national_insurance: payment.national_insurance.to_f,
        net_employment_income: payment.net_employment_income.to_f,
      }
    end

    def employments
      legal_aid_application.employments
    end
  end
end
