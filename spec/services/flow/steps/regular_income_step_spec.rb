require "rails_helper"

RSpec.describe Flow::Steps::RegularIncomeStep do
  describe "#path" do
    it "returns the regular incomes path when called" do
      legal_aid_application = create(:legal_aid_application)

      path = described_class.path.call(legal_aid_application)

      expected_path = "/providers/applications/#{legal_aid_application.id}/" \
                      "means/regular_incomes?locale=en"
      expect(path).to eq expected_path
    end
  end

  describe "#forward" do
    context "when the application has income types" do
      it "returns the cash incomes step when called" do
        legal_aid_application = instance_double(
          LegalAidApplication,
          "income_types?" => true,
        )

        forward = described_class.forward.call(legal_aid_application)

        expect(forward).to eq(:cash_incomes)
      end
    end

    context "when the application does not have income types" do
      it "returns the student finances step when called" do
        legal_aid_application = instance_double(
          LegalAidApplication,
          "income_types?" => false,
        )

        forward = described_class.forward.call(legal_aid_application)

        expect(forward).to eq(:student_finances)
      end
    end
  end

  describe "#check_answers" do
    context "when the application has income types" do
      it "returns the cash incomes step when called" do
        legal_aid_application = instance_double(
          LegalAidApplication,
          "income_types?" => true,
        )

        check_answers = described_class.check_answers.call(legal_aid_application)

        expect(check_answers).to eq(:cash_incomes)
      end
    end

    context "when the application does not have income types" do
      it "returns the means summaries step when called" do
        legal_aid_application = instance_double(
          LegalAidApplication,
          "income_types?" => false,
        )

        check_answers = described_class.check_answers.call(legal_aid_application)

        expect(check_answers).to eq(:means_summaries)
      end
    end
  end
end
