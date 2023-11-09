require "rails_helper"

module CFE
  module V6
    RSpec.describe Result do
      let(:cfe_result) { create(:cfe_v6_result) }
      let(:ineligible_gross_income_result) { create(:cfe_v6_result, :ineligible_gross_income) }
      let(:ineligible_disposable_income_result) { create(:cfe_v6_result, :ineligible_disposable_income) }
      let(:ineligible_capital_result) { create(:cfe_v6_result, :ineligible_capital) }

      describe "#gross_income_results" do
        context "when overall result is eligible" do
          it "returns pending for each proceeding" do
            expect(cfe_result.gross_income_results).to eq %w[pending pending]
          end
        end

        context "when overall result is ineligible because gross income is above upper threshold" do
          it "returns ineligible for each proceeding" do
            expect(ineligible_gross_income_result.gross_income_results).to eq %w[ineligible ineligible]
          end
        end
      end

      describe "#disposable_income_results" do
        context "when overall result is eligible" do
          it "returns pending for each proceeding" do
            expect(cfe_result.disposable_income_results).to eq %w[pending pending]
          end
        end

        context "when overall result is ineligible because disposable income is above upper threshold" do
          it "returns ineligible for each proceeding" do
            expect(ineligible_disposable_income_result.disposable_income_results).to eq %w[ineligible ineligible]
          end
        end
      end

      describe "#capital_results" do
        context "when overall result is eligible" do
          it "returns eligible for each proceeding" do
            expect(cfe_result.capital_results).to eq %w[eligible eligible]
          end
        end

        context "when overall result is ineligible because disposable capital is above upper threshold" do
          it "returns ineligible for each proceeding" do
            expect(ineligible_capital_result.capital_results).to eq %w[ineligible ineligible]
          end
        end
      end
    end
  end
end
