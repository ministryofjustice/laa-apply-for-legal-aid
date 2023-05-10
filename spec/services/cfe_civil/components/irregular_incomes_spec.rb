require "rails_helper"

RSpec.describe CFECivil::Components::IrregularIncomes do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

  context "when there are no irregular payments" do
    it "returns the expected, empty, JSON block" do
      expect(call).to eq({
        irregular_incomes: {
          payments: [],
        },
      }.to_json)
    end
  end

  context "when payments are recorded" do
    before do
      create(:irregular_income, legal_aid_application:, amount: 3628.07)
    end

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
