module CFE
  class CreateCapitalsService < BaseService
    OTHER_ASSET_FIELDS = {
      timeshare_property_value: 'Timeshare property',
      land_value: 'Land',
      valuable_items_value: 'Valuable items',
      inherited_assets_value: 'Inherited assets',
      money_owed_value: 'Money owed to applicant',
      trust_value: 'Trusts'
    }.freeze

    SAVINGS_AMOUNT_FIELDS = {
      offline_accounts: 'Off-line bank accounts',
      cash: 'Cash',
      other_person_account: "Signatory on other person's account",
      national_savings: 'National savings',
      plc_shares: 'Shares in PLC',
      peps_unit_trusts_capital_bonds_gov_stocks: 'PEPs, unit trusts, capital bonds and government stocks',
      life_assurance_endowment_policy: 'Life assurance and endowment policies not linked to a mortgage'
    }.freeze

    def cfe_url_path
      "/assessments/#{@submission.assessment_id}/capitals"
    end

    def request_body
      {
        "bank_accounts": bank_account_assets,
        "non_liquid_capital": itemised_other_assets
      }.to_json
    end

    private

    def process_response
      @submission.capitals_created!
    end

    def other_assets_declaration
      @other_assets_declaration ||= legal_aid_application.other_assets_declaration
    end

    def itemised_other_assets
      array_of_hashes_for(other_assets_declaration, OTHER_ASSET_FIELDS)
    end

    def bank_account_assets
      [savings_amounts, bank_accounts].flatten.compact
    end

    def bank_accounts
      # passported applicants don't have online bank accounts, so this is always empty until
      # such time as non-passported applicants are added to the system
      []
    end

    def savings_amounts
      array_of_hashes_for(savings_amount, SAVINGS_AMOUNT_FIELDS)
    end

    def array_of_hashes_for(model, field_names_and_descriptions)
      return nil if model.nil?

      items = []
      field_names_and_descriptions.each do |field_name, field_description|
        value = model.__send__(field_name)
        items << description_and_value(field_description, value) if not_nil_or_zero?(value)
      end
      items
    end

    def description_and_value(description, value)
      {
        'description' => description,
        'value' => value
      }
    end

    def not_nil_or_zero?(value)
      value.present? && value.nonzero?
    end

    def savings_amount
      @savings_amount ||= legal_aid_application.savings_amount
    end
  end
end
