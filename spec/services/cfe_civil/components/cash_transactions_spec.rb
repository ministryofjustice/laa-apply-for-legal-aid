require "rails_helper"

RSpec.describe CFECivil::Components::CashTransactions do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner) }

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

  context "when applicant cash transactions exist" do
    let(:benefits) { create(:transaction_type, :benefits) }
    let!(:first_benefits_month) { create(:cash_transaction, :credit_month1, legal_aid_application:, owner_type: "Applicant", owner_id: legal_aid_application.applicant.id, amount: 123.0, transaction_type: benefits) }
    let!(:second_benefits_month) { create(:cash_transaction, :credit_month2, legal_aid_application:, owner_type: "Applicant", owner_id: legal_aid_application.applicant.id, amount: 234.0, transaction_type: benefits) }
    let!(:third_benefits_month) { create(:cash_transaction, :credit_month3, legal_aid_application:, owner_type: "Applicant", owner_id: legal_aid_application.applicant.id, amount: 345.0, transaction_type: benefits) }
    let(:maintenance_out) { create(:transaction_type, :maintenance_out) }
    let!(:first_maintenance_month) { create(:cash_transaction, :credit_month1, legal_aid_application:, owner_type: "Applicant", owner_id: legal_aid_application.applicant.id, amount: 123.0, transaction_type: maintenance_out) }
    let!(:second_maintenance_month) { create(:cash_transaction, :credit_month2, legal_aid_application:, owner_type: "Applicant", owner_id: legal_aid_application.applicant.id, amount: 234.0, transaction_type: maintenance_out) }
    let!(:third_maintenance_month) { create(:cash_transaction, :credit_month3, legal_aid_application:, owner_type: "Applicant", owner_id: legal_aid_application.applicant.id, amount: 345.0, transaction_type: maintenance_out) }

    before do
      create(:cash_transaction, :credit_month1, legal_aid_application:, owner_type: "Partner", owner_id: legal_aid_application.partner.id, amount: 456.0, transaction_type: benefits)
      create(:cash_transaction, :credit_month2, legal_aid_application:, owner_type: "Partner", owner_id: legal_aid_application.partner.id, amount: 789.0, transaction_type: benefits)
      create(:cash_transaction, :credit_month3, legal_aid_application:, owner_type: "Partner", owner_id: legal_aid_application.partner.id, amount: 890.0, transaction_type: benefits)
    end

    context "when no owner_type is specified" do
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

    context "when partner is specified as owner" do
      subject(:call) { described_class.call(legal_aid_application, "Partner") }

      let(:partner_transactions) { legal_aid_application.cash_transactions.where(owner_type: "Partner") }
      let(:month_three) { partner_transactions.find_by(transaction_date: Date.current.at_beginning_of_month - 3.months) }
      let(:month_two) { partner_transactions.find_by(transaction_date: Date.current.at_beginning_of_month - 2.months) }
      let(:month_one) { partner_transactions.find_by(transaction_date: Date.current.at_beginning_of_month - 1.month) }

      it "returns expected JSON structure" do
        expect(call).to eq({
          cash_transactions: {
            income: [
              {
                category: "benefits",
                payments: [
                  { date: month_three.transaction_date, amount: 890.0, client_id: month_three.id },
                  { date: month_two.transaction_date, amount: 789.0, client_id: month_two.id },
                  { date: month_one.transaction_date, amount: 456.0, client_id: month_one.id },
                ],
              },
            ],
            outgoings: [],
          },
        }.to_json)
      end
    end
  end
end
