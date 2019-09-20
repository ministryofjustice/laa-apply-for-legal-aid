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
        value: legal_aid_application.property_value,
        outstanding_mortgage: legal_aid_application.outstanding_mortgage_amount,
        percentage_owned: legal_aid_application.percentage_home,
        shared_with_housing_assoc: false # Place holder - Expect param to be removed from API
      }
    end

    def second_home
      {
        value: or_zero(other_assets_declaration&.second_home_value),
        outstanding_mortgage: or_zero(other_assets_declaration&.second_home_mortgage),
        percentage_owned: or_zero(other_assets_declaration&.second_home_percentage),
        shared_with_housing_assoc: false # Place holder - Expect param to be removed from API
      }
    end

    def or_zero(number)
      number || 0
    end

    def process_response
      submission.properties_created!
    end
  end
end
