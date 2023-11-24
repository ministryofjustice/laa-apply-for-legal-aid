require "rails_helper"

module CFE
  module V6
    RSpec.describe Result do
      let(:cfe_result_with_partner) { create(:cfe_v6_result, :with_employments, :with_partner) }
      let(:with_maintenance) { create(:cfe_v6_result, :with_partner, :with_maintenance_received) }
      let(:with_student_finance) { create(:cfe_v6_result, :with_partner, :with_student_finance_received) }
      let(:with_total_deductions) { create(:cfe_v6_result, :with_partner, :with_total_deductions) }
      let(:with_monthly_income_equivalents) { create(:cfe_v6_result, :with_partner, :with_monthly_income_equivalents) }
      let(:with_monthly_outgoing_equivalents) { create(:cfe_v6_result, :with_partner, :with_monthly_outgoing_equivalents) }
      let(:with_total_gross_income) { create(:cfe_v6_result, :with_partner, :with_total_gross_income) }
      let(:with_employments) { create(:cfe_v6_result, :with_partner, :with_employments) }
      let(:with_no_employments) { create(:cfe_v6_result, :with_partner, :with_no_employments) }
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner, :with_restrictions, :with_cfe_v6_result) }
      let(:cfe_submission) { create(:cfe_submission, legal_aid_application:) }

      describe "gross_income_breakdown" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the gross income breakdown for the client" do
            expect(cfe_result_with_partner.gross_income_breakdown(partner:)[:state_benefits][:monthly_equivalents][:all_sources]).to eq(75.0)
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the gross income breakdown for the partner" do
            expect(cfe_result_with_partner.gross_income_breakdown(partner:)[:state_benefits][:monthly_equivalents][:all_sources]).to eq(86.67)
          end
        end
      end

      describe "gross_income_summary" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the gross income summary for the client" do
            expect(cfe_result_with_partner.gross_income_summary(partner:)[:total_gross_income]).to eq(0.0)
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the gross income summary for the partner" do
            expect(cfe_result_with_partner.gross_income_summary(partner:)[:total_gross_income]).to eq(150.0)
          end
        end
      end

      describe "total_gross_income_assessed" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the total gross income for the client" do
            expect(cfe_result_with_partner.total_gross_income_assessed(partner:)).to eq(0.0)
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the total gross income for the partner" do
            expect(cfe_result_with_partner.total_gross_income_assessed(partner:)).to eq(150.0)
          end
        end
      end

      describe "total_disposable_income_assessed" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the total disposable income for the client only" do
            expect(cfe_result_with_partner.total_disposable_income_assessed(partner:)).to eq(0.0)
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the total disposable income for the client and the partner" do
            expect(cfe_result_with_partner.total_disposable_income_assessed(partner:)).to eq(2577.11)
          end
        end
      end

      describe "total_disposable_income_summary" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the disposable income summary for the client" do
            expect(cfe_result_with_partner.disposable_income_summary(partner:)[:total_disposable_income]).to eq(0.0)
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the disposable income summary for the partner" do
            expect(cfe_result_with_partner.disposable_income_summary(partner:)[:total_disposable_income]).to eq(2577.11)
          end
        end
      end

      describe "disposable_income_breakdown" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the disposable income breakdown for the client" do
            expect(cfe_result_with_partner.disposable_income_breakdown(partner:)[:monthly_equivalents][:all_sources][:rent_or_mortgage]).to eq(125.0)
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the disposable income breakdown for the partner" do
            expect(cfe_result_with_partner.disposable_income_breakdown(partner:)[:monthly_equivalents][:all_sources][:rent_or_mortgage]).to eq(0.0)
          end
        end
      end

      describe "employment_income" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the employment income for the client" do
            expect(cfe_result_with_partner.employment_income(partner:)[:gross_income]).to eq(2143.97)
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the employment income for the partner" do
            expect(cfe_result_with_partner.employment_income(partner:)[:gross_income]).to eq(2229.17)
          end
        end
      end

      describe "enployment_income_gross_income" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the employment income for the client" do
            expect(cfe_result_with_partner.employment_income_gross_income(partner:)).to eq(2143.97)
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the employment income for the partner" do
            expect(cfe_result_with_partner.employment_income_gross_income(partner:)).to eq(2229.17)
          end
        end
      end
    end
  end
end
