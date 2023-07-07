require "rails_helper"

RSpec.describe CFECivil::Components::Outgoings do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

  context "when there are no outgoings" do
    it "returns the expected, empty, JSON block" do
      expect(call).to eq({
        outgoings: [],
      }.to_json)
    end
  end

  context "when there outgoings have been created and the applicant does not have a mortgage" do
    let(:bank_provider) { create(:bank_provider, applicant: legal_aid_application.applicant) }
    let(:bank_account) { create(:bank_account, bank_provider:) }
    let!(:rent_10_days_ago) { create(:bank_transaction, :rent_or_mortgage, bank_account:, happened_at: 10.days.ago, amount: 1150.0) }
    let!(:rent_40_days_ago) { create(:bank_transaction, :rent_or_mortgage, bank_account:, happened_at: 40.days.ago, amount: 1150.0) }
    let!(:child_care_15_days_ago) { create(:bank_transaction, :child_care, bank_account:, happened_at: 15.days.ago, amount: 234.56) }
    let!(:child_care_45_days_ago) { create(:bank_transaction, :child_care, bank_account:, happened_at: 45.days.ago, amount: 266.0) }

    it "returns the expected JSON block" do
      expect(call).to eq({
        outgoings: [
          {
            name: "child_care",
            payments: [
              { payment_date: 45.days.ago.strftime("%F"), amount: 266.0, client_id: child_care_45_days_ago.id },
              { payment_date: 15.days.ago.strftime("%F"), amount: 234.56, client_id: child_care_15_days_ago.id },
            ],
          },
          {
            name: "rent_or_mortgage",
            payments: [
              { payment_date: 40.days.ago.strftime("%F"), amount: 1150.0, client_id: rent_40_days_ago.id, housing_cost_type: "rent" },
              { payment_date: 10.days.ago.strftime("%F"), amount: 1150.0, client_id: rent_10_days_ago.id, housing_cost_type: "rent" },
            ],
          },
        ],
      }.to_json)
    end
  end

  context "when there outgoings have been created and the applicant has a mortgage" do
    let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_own_home_mortgaged) }
    let(:bank_provider) { create(:bank_provider, applicant: legal_aid_application.applicant) }
    let(:bank_account) { create(:bank_account, bank_provider:) }
    let!(:rent_10_days_ago) { create(:bank_transaction, :rent_or_mortgage, bank_account:, happened_at: 10.days.ago, amount: 1150.0) }
    let!(:rent_40_days_ago) { create(:bank_transaction, :rent_or_mortgage, bank_account:, happened_at: 40.days.ago, amount: 1150.0) }
    let!(:child_care_15_days_ago) { create(:bank_transaction, :child_care, bank_account:, happened_at: 15.days.ago, amount: 234.56) }
    let!(:child_care_45_days_ago) { create(:bank_transaction, :child_care, bank_account:, happened_at: 45.days.ago, amount: 266.0) }

    it "returns the expected JSON block" do
      expect(call).to eq({
        outgoings: [
          {
            name: "child_care",
            payments: [
              { payment_date: 45.days.ago.strftime("%F"), amount: 266.0, client_id: child_care_45_days_ago.id },
              { payment_date: 15.days.ago.strftime("%F"), amount: 234.56, client_id: child_care_15_days_ago.id },
            ],
          },
          {
            name: "rent_or_mortgage",
            payments: [
              { payment_date: 40.days.ago.strftime("%F"), amount: 1150.0, client_id: rent_40_days_ago.id, housing_cost_type: "mortgage" },
              { payment_date: 10.days.ago.strftime("%F"), amount: 1150.0, client_id: rent_10_days_ago.id, housing_cost_type: "mortgage" },
            ],
          },
        ],
      }.to_json)
    end
  end
end
