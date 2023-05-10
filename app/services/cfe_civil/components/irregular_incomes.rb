module CFECivil
  module Components
    class IrregularIncomes < BaseDataBlock
      delegate :irregular_incomes, to: :legal_aid_application

      def call
        {
          irregular_incomes: {
            payments: irregular_incomes.map(&:as_json),
          },
        }.to_json
      end
    end
  end
end
