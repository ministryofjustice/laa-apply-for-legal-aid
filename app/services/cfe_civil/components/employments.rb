module CFECivil
  module Components
    class Employments < BaseDataBlock
      delegate :employments, to: :legal_aid_application

      def call
        if employment_and_payments?
          { employment_income: employment_income_payload }.to_json
        else
          {}.to_json
        end
      end

    private

      def employment_and_payments?
        legal_aid_application.hmrc_employment_income? && legal_aid_application.employment_payments.present?
      end

      def employment_income_payload
        index = 1
        employments.each_with_object([]) do |employment, payload|
          payload << employment_data(employment, index)
          index += 1
        end
      end

      def employment_data(employment, _job_num)
        {
          name: employment.name,
          client_id: employment.id,
          payments: employment_payments(employment),
        }
      end

      def employment_payments(employment)
        employment.employment_payments.each_with_object([]) { |payment, data| data << individual_payment_data(payment) }
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
    end
  end
end
