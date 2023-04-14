require "rails_helper"

RSpec.describe CFECivil::Components::CashTransactions do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

  context "when there are no cash_transactions" do
    it "returns expected JSON structure" do
      expect(call).to eq({
        income: [],
        outgoings: [],
      }.to_json)
    end
  end

  context "when cash transactions exist" do
    let(:benefits) { create(:transaction_type, :benefits) }
    let!(:benefits1) { create(:cash_transaction, :credit_month1, legal_aid_application:, amount: 123.0, transaction_type: benefits) }
    let!(:benefits2) { create(:cash_transaction, :credit_month2, legal_aid_application:, amount: 234.0, transaction_type: benefits) }
    let!(:benefits3) { create(:cash_transaction, :credit_month3, legal_aid_application:, amount: 345.0, transaction_type: benefits) }
    let(:maintenance_out) { create(:transaction_type, :maintenance_out) }
    let!(:maintenance_out1) { create(:cash_transaction, :credit_month1, legal_aid_application:, amount: 123.0, transaction_type: maintenance_out) }
    let!(:maintenance_out2) { create(:cash_transaction, :credit_month2, legal_aid_application:, amount: 234.0, transaction_type: maintenance_out) }
    let!(:maintenance_out3) { create(:cash_transaction, :credit_month3, legal_aid_application:, amount: 345.0, transaction_type: maintenance_out) }

    it "returns expected JSON structure" do
      expect(call).to eq({
        income: [
          {
            category: "benefits",
            payments: [
              { date: "2023-01-01", amount: 345.0, client_id: benefits3.id },
              { date: "2023-02-01", amount: 234.0, client_id: benefits2.id },
              { date: "2023-03-01", amount: 123.0, client_id: benefits1.id },
            ],
          },
        ],
        outgoings: [
          {
            category: "maintenance_out",
            payments: [
              { date: "2023-01-01", amount: 345.0, client_id: maintenance_out3.id },
              { date: "2023-02-01", amount: 234.0, client_id: maintenance_out2.id },
              { date: "2023-03-01", amount: 123.0, client_id: maintenance_out1.id },
            ],
          },
        ],
      }.to_json)
    end
  end
end
