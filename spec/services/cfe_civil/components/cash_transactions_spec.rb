require "rails_helper"

RSpec.describe CFECivil::Components::CashTransactions do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

  context "when there are no cash_transactions" do
    it "returns expected JSON structure" do
      expect(call).to eq({
        cash_transactions: {
          income: [],
          outgoings: [],
        },
      }.to_json)
    end
  end

  context "when cash transactions exist" do
    let(:benefits) { create(:transaction_type, :benefits) }
    let!(:first_benefits_month) { create(:cash_transaction, :credit_month1, legal_aid_application:, owner_type: "Applicant", owner_id: legal_aid_application.applicant.id, amount: 123.0, transaction_type: benefits) }
    let!(:second_benefits_month) { create(:cash_transaction, :credit_month2, legal_aid_application:, owner_type: "Applicant", owner_id: legal_aid_application.applicant.id, amount: 234.0, transaction_type: benefits) }
    let!(:third_benefits_month) { create(:cash_transaction, :credit_month3, legal_aid_application:, owner_type: "Applicant", owner_id: legal_aid_application.applicant.id, amount: 345.0, transaction_type: benefits) }
    let(:maintenance_out) { create(:transaction_type, :maintenance_out) }
    let!(:first_maintenance_month) { create(:cash_transaction, :credit_month1, legal_aid_application:, owner_type: "Applicant", owner_id: legal_aid_application.applicant.id, amount: 123.0, transaction_type: maintenance_out) }
    let!(:second_maintenance_month) { create(:cash_transaction, :credit_month2, legal_aid_application:, owner_type: "Applicant", owner_id: legal_aid_application.applicant.id, amount: 234.0, transaction_type: maintenance_out) }
    let!(:third_maintenance_month) { create(:cash_transaction, :credit_month3, legal_aid_application:, owner_type: "Applicant", owner_id: legal_aid_application.applicant.id, amount: 345.0, transaction_type: maintenance_out) }

    it "returns expected JSON structure" do
      expect(call).to eq({
        cash_transactions: {
          income: [
            {
              category: "benefits",
              payments: [
                { date: Date.current.at_beginning_of_month - 3.months, amount: 345.0, client_id: third_benefits_month.id },
                { date: Date.current.at_beginning_of_month - 2.months, amount: 234.0, client_id: second_benefits_month.id },
                { date: Date.current.at_beginning_of_month - 1.month, amount: 123.0, client_id: first_benefits_month.id },
              ],
            },
          ],
          outgoings: [
            {
              category: "maintenance_out",
              payments: [
                { date: Date.current.at_beginning_of_month - 3.months, amount: 345.0, client_id: third_maintenance_month.id },
                { date: Date.current.at_beginning_of_month - 2.months, amount: 234.0, client_id: second_maintenance_month.id },
                { date: Date.current.at_beginning_of_month - 1.month, amount: 123.0, client_id: first_maintenance_month.id },
              ],
            },
          ],
        },
      }.to_json)
    end
  end
end
