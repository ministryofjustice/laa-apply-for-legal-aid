require "rails_helper"

RSpec.describe CFECivil::Components::StateBenefits do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

  context "when there are no state_benefits" do
    it "returns the expected, empty, JSON block" do
      expect(call).to eq({
        state_benefits: [],
      }.to_json)
    end
  end

  context "when basic benefit bank transactions exist" do
    let(:bank_provider) { create(:bank_provider, applicant: legal_aid_application.applicant) }
    let(:bank_account) { create(:bank_account, bank_provider:) }
    let!(:transaction1) { create(:bank_transaction, :benefits, bank_account:, amount: "123.45", happened_at: 10.days.ago) }
    let!(:transaction2) { create(:bank_transaction, :benefits, bank_account:, amount: "123.45", happened_at: 40.days.ago) }
    let!(:transaction3) { create(:bank_transaction, :benefits, bank_account:, amount: "123.45", happened_at: 70.days.ago) }

    it "returns the expected JSON block" do
      expect(call).to eq({
        state_benefits: [
          {
            name: "child_benefit",
            payments: [
              {
                date: 70.days.ago.strftime("%Y-%m-%d"),
                amount: 123.45,
                client_id: transaction3.id,
              },
              {
                date: 40.days.ago.strftime("%Y-%m-%d"),
                amount: 123.45,
                client_id: transaction2.id,
              },
              {
                date: 10.days.ago.strftime("%Y-%m-%d"),
                amount: 123.45,
                client_id: transaction1.id,
              },
            ],
          },
        ],
      }.to_json)
    end
  end

  context "when flagged benefit bank transactions exist" do
    let(:bank_provider) { create(:bank_provider, applicant: legal_aid_application.applicant) }
    let(:bank_account) { create(:bank_account, bank_provider:) }
    let!(:transaction1) { create(:bank_transaction, :unknown_benefits, :flagged_multi_benefits, bank_account:, amount: "321.99", happened_at: 10.days.ago) }

    it "returns the expected JSON block" do
      expect(call).to eq({
        state_benefits: [
          {
            name: "unknown",
            payments: [
              {
                date: 10.days.ago.strftime("%Y-%m-%d"),
                amount: 321.99,
                client_id: transaction1.id,
                flags: { multi_benefit: true },
              },
            ],
          },
        ],
      }.to_json)
    end
  end
end
