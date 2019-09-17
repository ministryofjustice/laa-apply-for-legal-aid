module CFE
  class CreateCapitalsService < BaseService
    OTHER_ASSET_FIELDS = %i[
      timeshare_property_value
      land_value
      valuable_items_value
      inherited_assets_value
      money_owed_value
      trust_value
    ].freeze

    private

    def cfe_url_path
      "/assessments/#{@submission.assessment_id}/capitals"
    end

    def request_body
      {
        "bank_accounts": [
          # passported clients do not have bank accounts
        ],
        "non_liquid_capital": itemised_other_assets
      }.to_json
    end

    def process_response
      @submission.capitals_created!
    end

    def other_assets_declaration
      @other_assets_declaration ||= legal_aid_application.other_assets_declaration
    end

    def itemised_other_assets
      items = []
      OTHER_ASSET_FIELDS.each do |field_name|
        description = field_name.to_s.sub(/_value$/, '').humanize
        value = other_assets_declaration.__send__(field_name)
        items << description_and_value(description, value) if not_nil_or_zero?(value)
      end
      items
    end

    def not_nil_or_zero?(value)
      value.present? && value.nonzero?
    end

    def description_and_value(description, value)
      {
        'description' => description,
        'value' => value
      }
    end
  end
end
