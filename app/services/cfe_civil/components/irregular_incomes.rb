module CFECivil
  module Components
    class IrregularIncomes < BaseDataBlock
      def call
        {
          irregular_incomes: {
            payments: payment_data,
          },
        }.to_json
      end

    private

      def payment_data
        if student_finance_data?
          [
            {
              income_type: "student_loan",
              frequency: "annual",
              amount: student_finance_amount.to_f,
            },
          ]
        else
          []
        end
      end

      def student_finance_data?
        legal_aid_application.applicant.student_finance? && student_finance_amount.positive?
      end

      def student_finance_amount
        legal_aid_application.applicant.student_finance_amount
      end
    end
  end
end
