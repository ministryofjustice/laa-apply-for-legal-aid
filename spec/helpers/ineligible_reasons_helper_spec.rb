require "rails_helper"

RSpec.describe IneligibleReasonsHelper do
  let(:eligible_result) { create(:cfe_v6_result) }
  let(:ineligible_gross_income_result) { create(:cfe_v6_result, :ineligible_gross_income) }
  let(:ineligible_disposable_income_result) { create(:cfe_v6_result, :ineligible_disposable_income) }
  let(:ineligible_capital_result) { create(:cfe_v6_result, :ineligible_capital) }
  let(:ineligible_disposable_income_and_capital_result) { create(:cfe_v6_result, :fake_ineligible_disposable_income_and_capital) }

  describe ".ineligible_reasons" do
    subject(:reasons) { ineligible_reasons(cfe_result) }

    context "when overall cfe result is eligible" do
      let(:cfe_result) { eligible_result }

      it "returns an empty string" do
        expect(reasons).to eq ""
      end
    end

    context "when overall cfe result is ineligible and applicant's gross income is above upper threshold" do
      let(:cfe_result) { ineligible_gross_income_result }

      it "returns 'gross income'" do
        expect(reasons).to eq "gross income"
      end
    end

    context "when overall cfe result is ineligible and applicant's disposable income is above upper threshold" do
      let(:cfe_result) { ineligible_disposable_income_result }

      it "returns 'disposable income'" do
        expect(reasons).to eq "disposable income"
      end
    end

    context "when overall cfe result is ineligible and applicant's capital is above upper threshold" do
      let(:cfe_result) { ineligible_capital_result }

      it "returns 'disposable capital'" do
        expect(reasons).to eq "disposable capital"
      end
    end

    context "when cfe returns ineligible for multiple categories; disposable income and capital" do
      let(:cfe_result) { ineligible_disposable_income_and_capital_result }

      it "returns a bulleted list of disposable income and capital" do
        expect(reasons).to eq ":<ul class='govuk-list govuk-list--bullet'><li>disposable income</li><li>disposable capital</li></ul>"
      end
    end
  end
end
