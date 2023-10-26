module CFECivil
  module Components
    class IrregularIncomes < BaseDataBlock
      def call
        payment_data.to_json
      end

    private

      def payment_data
        if student_finance_data? && owner_type.eql?("Partner")
          {
            irregular_incomes: [
              {
                income_type: "student_loan",
                frequency: "annual",
                amount: student_finance_amount.to_f,
              },
            ],
          }
        elsif student_finance_data?
          {
            irregular_incomes: {
              payments: [
                {
                  income_type: "student_loan",
                  frequency: "annual",
                  amount: student_finance_amount.to_f,
                },
              ],
            },
          }
        elsif owner_type.eql?("Partner")
          {
            irregular_incomes: [],
          }
        else
          {
            irregular_incomes: {
              payments: [],
            },
          }
        end
      end

      def party
        @party ||= legal_aid_application.send(owner_type.downcase)
      end

      def student_finance_data?
        party.student_finance? && student_finance_amount.positive?
      end

      def student_finance_amount
        party.student_finance_amount
      end
    end
  end
end
