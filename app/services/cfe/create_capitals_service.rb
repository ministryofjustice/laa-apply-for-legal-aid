module CFE
  class CreateCapitalsService < BaseService
    OTHER_ASSET_FIELDS = {
      timeshare_property_value: 'Timeshare property',
      land_value: 'Land',
      valuable_items_value: 'Any valuable items worth more than £500',
      inherited_assets_value: 'Money or assets from the estate of a person who has died',
      money_owed_value: 'Money owed to applicant',
      trust_value: 'Interest in a trust'
    }.freeze

    SAVINGS_AMOUNT_FIELDS = {
      offline_current_accounts: 'Current accounts',
      offline_savings_accounts: 'Savings accounts',
      cash: 'Money not in a bank account',
      other_person_account: "Access to another person's bank account",
      national_savings: 'ISAs, National Savings Certificates and Premium Bonds',
      plc_shares: 'Shares in a public limited company',
      peps_unit_trusts_capital_bonds_gov_stocks: 'PEPs, unit trusts, capital bonds and government stocks',
      life_assurance_endowment_policy: 'Life assurance and endowment policies not linked to a mortgage'
    }.freeze

    def cfe_url_path
      "/assessments/#{@submission.assessment_id}/capitals"
    end

    def request_body
      {
        bank_accounts: bank_account_assets,
        non_liquid_capital: itemised_other_assets
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
      [current_account_balance, savings_account_balance].compact
    end

    def current_account_balance
      return if legal_aid_application.online_current_accounts_balance.blank?

      {
        description: 'Online current accounts',
        value: legal_aid_application.online_current_accounts_balance
      }
    end

    def savings_account_balance
      return if legal_aid_application.online_savings_accounts_balance.blank?

      {
        description: 'Online savings accounts',
        value: legal_aid_application.online_savings_accounts_balance
      }
    end

    def savings_amounts
      array_of_hashes_for(savings_amount, SAVINGS_AMOUNT_FIELDS)
    end

    def array_of_hashes_for(model, field_names_and_descriptions)
      return nil if model.nil?

      items = []
      field_names_and_descriptions.each do |field_name, field_description|
        value = model.__send__(field_name)
        next if value.nil?

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
