require "rails_helper"

RSpec.describe CFECivil::Components::IrregularIncomes do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, applicant:) }

  context "when there are no irregular payments" do
    let(:applicant) { create(:applicant, student_finance: false) }

    it "returns the expected, empty, JSON block" do
      expect(call).to eq({
        irregular_incomes: {
          payments: [],
        },
      }.to_json)
    end
  end

  context "when payments are recorded" do
    let(:applicant) { create(:applicant, student_finance: true, student_finance_amount: 3628.07) }

    it "returns the expected JSON block" do
      expect(call).to eq({
        irregular_incomes: {
          payments: [
            {
              income_type: "student_loan",
              frequency: "annual",
              amount: 3628.07,
            },
          ],
        },
      }.to_json)
    end
  end
end
