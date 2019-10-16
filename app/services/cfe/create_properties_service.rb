module CFE
  class CreatePropertiesService < BaseService
    delegate :other_assets_declaration, to: :legal_aid_application

    def cfe_url_path
      "/assessments/#{@submission.assessment_id}/properties"
    end

    def request_body
      {
        properties: {
          main_home: main_home,
          additional_properties: [second_home]
        }
      }.to_json
    end

    def main_home
      {
        value: legal_aid_application.property_value || 0.0,
        outstanding_mortgage: legal_aid_application.outstanding_mortgage_amount || 0.0,
        percentage_owned: legal_aid_application.percentage_home || 0.0,
        shared_with_housing_assoc: main_home_shared_with_housing_association_or_landlord?
      }
    end

    def second_home
      {
        value: or_zero(other_assets_declaration&.second_home_value),
        outstanding_mortgage: or_zero(other_assets_declaration&.second_home_mortgage),
        percentage_owned: or_zero(other_assets_declaration&.second_home_percentage),
        shared_with_housing_assoc: false # Data not gathered for second home
      }
    end

    def or_zero(number)
      number || 0
    end

    def process_response
      submission.properties_created!
    end

    def main_home_shared_with_housing_association_or_landlord?
      legal_aid_application.shared_ownership == 'housing_assocation_or_landlord'
    end
  end
end
