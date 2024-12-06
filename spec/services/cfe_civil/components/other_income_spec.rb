require "rails_helper"

RSpec.describe CFECivil::Components::OtherIncome do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

  context "when there is no other_income" do
    it "returns the expected, empty, JSON block" do
      expect(call).to eq({
        other_incomes: [],
      }.to_json)
    end
  end

  context "when incomes are recorded" do
    before do
      Populators::TransactionTypePopulator.call
      create(:bank_transaction, :benefits, bank_account:)
      create(:bank_transaction, :child_care, bank_account:)
      create(:bank_transaction, :rent_or_mortgage, bank_account:)
    end

    let(:bank_provider) { create(:bank_provider, applicant: legal_aid_application.applicant) }
    let(:bank_account) { create(:bank_account, bank_provider:) }
    let!(:maintenance_today) { create(:bank_transaction, :maintenance_in, bank_account:, amount: 250.0, happened_at: Time.zone.today) }
    let!(:maintenance_week_ago) { create(:bank_transaction, :maintenance_in, bank_account:, amount: 125.0, happened_at: 1.week.ago) }
    let!(:friends_today) { create(:bank_transaction, :friends_or_family, bank_account:, amount: 60.0, happened_at: Time.zone.today) }
    let!(:friends_week_ago) { create(:bank_transaction, :friends_or_family, bank_account:, amount: 60.0, happened_at: 1.week.ago) }
    let(:today) { Time.zone.today.strftime("%Y-%m-%d") }
    let(:one_week_ago) { 1.week.ago.strftime("%Y-%m-%d") }
    let(:two_weeks_ago) { 2.weeks.ago.strftime("%Y-%m-%d") }

    it "returns the expected JSON block" do
      expect(call).to eq({
        other_incomes: [
          {
            source: "Friends or family",
            payments: [
              { date: one_week_ago, amount: 60.0, client_id: friends_week_ago.id },
              { date: today, amount: 60.0, client_id: friends_today.id },
            ],
          },
          {
            source: "Maintenance in",
            payments: [
              { date: one_week_ago, amount: 125.0, client_id: maintenance_week_ago.id },
              { date: today, amount: 250.0, client_id: maintenance_today.id },
            ],
          },
        ],
      }.to_json)
    end
  end
end
