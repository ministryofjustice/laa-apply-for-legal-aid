require "rails_helper"

RSpec.describe CFECivil::Components::RegularTransactions do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

  context "when there are no regular transactions" do
    it "returns the expected, empty, JSON block" do
      expect(call).to eq({
        regular_transactions: [],
      }.to_json)
    end
  end

  context "when there are regular transactions" do
    before do
      create(:regular_transaction,
             :maintenance_out,
             legal_aid_application:,
             amount: 222.22,
             frequency: "monthly")
      create(:regular_transaction,
             :maintenance_in,
             legal_aid_application:,
             amount: 111.11,
             frequency: "monthly")
    end

    it "returns the expected JSON block" do
      expect(JSON.parse(call)).to match_json_expression({
        regular_transactions: [
          {
            category: "maintenance_in",
            operation: "credit",
            amount: 111.11,
            frequency: "monthly",
          },
          {
            category: "maintenance_out",
            operation: "debit",
            amount: 222.22,
            frequency: "monthly",
          },
        ],
      })
    end
  end
end
