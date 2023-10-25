require "rails_helper"

RSpec.describe CFECivil::Components::Capitals do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, with_bank_accounts: 6) }
  let(:submission) { create(:cfe_submission, aasm_state: "applicant_created", legal_aid_application:) }
  let(:online_current_balance) { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  let(:online_savings_balance) { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  let(:offline_current_balance) { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  let(:offline_savings_balance) { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  let(:offline_partner_current_balance) { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  let(:offline_partner_savings_balance) { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  let(:offline_joint_current_balance) { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  let(:offline_joint_savings_balance) { Faker::Number.decimal(l_digits: 3, r_digits: 2) }

  before do
    create(:other_assets_declaration,
           timeshare_property_value: 555.55,
           land_value: 777.77,
           valuable_items_value: 888.88,
           trust_value: 999.0,
           legal_aid_application:,
           inherited_assets_value: nil,
           money_owed_value: 0.0)
    allow(legal_aid_application).to receive(:online_savings_accounts_balance).and_return(online_savings_balance)
    allow(legal_aid_application).to receive(:online_current_accounts_balance).and_return(online_current_balance)
    create(:savings_amount,
           legal_aid_application:,
           offline_current_accounts: offline_current_balance,
           offline_savings_accounts: offline_savings_balance,
           partner_offline_current_accounts: offline_partner_current_balance,
           partner_offline_savings_accounts: offline_partner_savings_balance,
           joint_offline_current_accounts: offline_joint_current_balance,
           joint_offline_savings_accounts: offline_joint_savings_balance)
  end

  describe ".call" do
    context "when invoked with no owner" do
      it "returns json in the expected format with only the applicant bank values" do
        expect(call).to eq({
          capitals: {
            bank_accounts: [
              { description: "Current accounts", value: offline_current_balance.to_s },
              { description: "Savings accounts", value: offline_savings_balance.to_s },
              { description: "Online current accounts", value: online_current_balance },
              { description: "Online savings accounts", value: online_savings_balance },
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

    context "when invoked with partner as owner" do
      subject(:call) { described_class.call(legal_aid_application, "Partner") }

      it "returns json in the expected format with the partner and joint bank values merged" do
        expect(call).to eq({
          capitals: {
            bank_accounts: [
              { description: "Partner current accounts", value: offline_partner_current_balance.to_s },
              { description: "Partner savings accounts", value: offline_partner_savings_balance.to_s },
              { description: "Joint current accounts", value: offline_joint_current_balance.to_s },
              { description: "Joint savings accounts", value: offline_joint_savings_balance.to_s },
            ],
            non_liquid_capital: [],
          },
        }.to_json)
      end
    end
  end
end
