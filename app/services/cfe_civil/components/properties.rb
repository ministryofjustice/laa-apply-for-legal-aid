module CFECivil
  module Components
    class Properties < BaseDataBlock
      delegate :other_assets_declaration, to: :legal_aid_application

      def call
        {
          properties: {
            main_home:,
            additional_properties: [second_home],
          },
        }.to_json
      end

    private

      def main_home
        {
          value: legal_aid_application.property_value.to_f,
          outstanding_mortgage: legal_aid_application.outstanding_mortgage_amount.to_f,
          percentage_owned: legal_aid_application.percentage_home.to_f,
          shared_with_housing_assoc: main_home_shared_with_housing_association_or_landlord?,
        }
      end

      def second_home
        {
          value: other_assets_declaration&.second_home_value.to_f,
          outstanding_mortgage: other_assets_declaration&.second_home_mortgage.to_f,
          percentage_owned: other_assets_declaration&.second_home_percentage.to_f,
          shared_with_housing_assoc: false, # Data not gathered for second home
        }
      end

      def main_home_shared_with_housing_association_or_landlord?
        legal_aid_application.shared_ownership == "housing_assocation_or_landlord"
      end
    end
  end
end
