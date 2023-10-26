require "rails_helper"

RSpec.describe CFECivil::Components::IrregularIncomes do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, applicant:, partner:) }

  context "when there are no irregular payments" do
    let(:applicant) { create(:applicant, student_finance: false) }
    let(:partner) { nil }

    it "returns the expected, empty, JSON block" do
      expect(call).to eq({
        irregular_incomes: {
          payments: [],
        },
      }.to_json)
    end
  end

  context "when both applicant and partner record student finance" do
    let(:applicant) { create(:applicant, student_finance: true, student_finance_amount: 3628.07) }
    let(:partner) { create(:partner, student_finance: true, student_finance_amount: 1234.56) }

    context "when no owner type is specified" do
      it "returns the expected JSON block with only the applicant data" do
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

    context "when partner is specified as owner type" do
      subject(:call) { described_class.call(legal_aid_application, "Partner") }

      it "returns the expected JSON block with only the partner data" do
        expect(call).to eq({
          irregular_incomes: [
            {
              income_type: "student_loan",
              frequency: "annual",
              amount: 1234.56,
            },
          ],
        }.to_json)
      end
    end
  end
end
