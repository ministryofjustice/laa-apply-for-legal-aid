require "rails_helper"

RSpec.describe CFECivil::Components::Capitals do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, with_bank_accounts: 6) }
  let(:submission) { create(:cfe_submission, aasm_state: "applicant_created", legal_aid_application:) }
  let(:current_balance) { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  let(:savings_balance) { Faker::Number.decimal(l_digits: 3, r_digits: 2) }

  before do
    create(:other_assets_declaration,
           timeshare_property_value: 555.55,
           land_value: 777.77,
           valuable_items_value: 888.88,
           trust_value: 999.0,
           legal_aid_application:,
           inherited_assets_value: nil,
           money_owed_value: 0.0)
    allow(legal_aid_application).to receive(:online_savings_accounts_balance).and_return(savings_balance)
    allow(legal_aid_application).to receive(:online_current_accounts_balance).and_return(current_balance)
  end

  describe ".call" do
    it "returns json in the expected format" do
      expect(call).to eq({
        capitals: {
          bank_accounts: [
            { description: "Online current accounts", value: current_balance },
            { description: "Online savings accounts", value: savings_balance },
          ],
          non_liquid_capital: [
            { description: "Timeshare property", value: "555.55" },
            { description: "Land", value: "777.77" },
            { description: "Any valuable items worth more than £500", value: "888.88" },
            { description: "Interest in a trust", value: "999.0" },
          ],
        },
      }.to_json)
    end
  end
end
