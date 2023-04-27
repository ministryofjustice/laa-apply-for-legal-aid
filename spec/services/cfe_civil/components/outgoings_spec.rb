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

  context "when there outgoings have been created" do
    let(:bank_provider) { create(:bank_provider, applicant: legal_aid_application.applicant) }
    let(:bank_account) { create(:bank_account, bank_provider:) }
    let!(:transaction1) { create(:bank_transaction, :rent_or_mortgage, bank_account:, happened_at: 10.days.ago, amount: 1150.0) }
    let!(:transaction2) { create(:bank_transaction, :rent_or_mortgage, bank_account:, happened_at: 40.days.ago, amount: 1150.0) }
    let!(:transaction3) { create(:bank_transaction, :child_care, bank_account:, happened_at: 15.days.ago, amount: 234.56) }
    let!(:transaction4) { create(:bank_transaction, :child_care, bank_account:, happened_at: 45.days.ago, amount: 266.0) }

    it "returns the expected JSON block" do
      expect(call).to eq({
        outgoings: [
          {
            name: "child_care",
            payments: [
              { payment_date: 45.days.ago.strftime("%F"), amount: 266.0, client_id: transaction4.id },
              { payment_date: 15.days.ago.strftime("%F"), amount: 234.56, client_id: transaction3.id },
            ],
          },
          {
            name: "rent_or_mortgage",
            payments: [
              { payment_date: 40.days.ago.strftime("%F"), amount: 1150.0, client_id: transaction2.id },
              { payment_date: 10.days.ago.strftime("%F"), amount: 1150.0, client_id: transaction1.id },
            ],
          },
        ],
      }.to_json)
    end
  end
end
