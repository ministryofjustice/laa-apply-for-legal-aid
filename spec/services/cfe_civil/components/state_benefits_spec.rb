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

  context "when manually categorised benefit bank transactions exist" do
    let(:bank_provider) { create(:bank_provider, applicant: legal_aid_application.applicant) }
    let(:bank_account) { create(:bank_account, bank_provider:) }
    let!(:benefits_10_days_old) { create(:bank_transaction, :benefits, :manually_chosen, bank_account:, amount: "123.45", happened_at: 10.days.ago) }
    let!(:benefits_40_days_old) { create(:bank_transaction, :benefits, :manually_chosen, bank_account:, amount: "123.45", happened_at: 40.days.ago) }
    let!(:benefits_70_days_old) { create(:bank_transaction, :benefits, :manually_chosen, bank_account:, amount: "123.45", happened_at: 70.days.ago) }

    it "returns the expected JSON block" do
      expect(call).to eq({
        state_benefits: [
          {
            name: "manually_chosen",
            payments: [
              {
                date: 70.days.ago.strftime("%Y-%m-%d"),
                amount: 123.45,
                client_id: benefits_70_days_old.id,
              },
              {
                date: 40.days.ago.strftime("%Y-%m-%d"),
                amount: 123.45,
                client_id: benefits_40_days_old.id,
              },
              {
                date: 10.days.ago.strftime("%Y-%m-%d"),
                amount: 123.45,
                client_id: benefits_10_days_old.id,
              },
            ],
          },
        ],
      }.to_json)
    end
  end
end
