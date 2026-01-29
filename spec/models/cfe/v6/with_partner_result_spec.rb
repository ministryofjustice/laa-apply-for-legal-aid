require "rails_helper"

module CFE
  module V6
    RSpec.describe Result do
      let(:cfe_result) { create(:cfe_v6_result, :with_employments, :with_partner) }

      # INCOME SUMMARIES

      describe "gross_income_breakdown" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the gross income breakdown for the client" do
            expect(cfe_result.gross_income_breakdown(partner:)[:state_benefits][:monthly_equivalents][:all_sources]).to eq 75.0
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the gross income breakdown for the partner" do
            expect(cfe_result.gross_income_breakdown(partner:)[:state_benefits][:monthly_equivalents][:all_sources]).to eq 86.67
          end
        end
      end

      describe "partner_gross_income_breakdown" do
        it "returns the gross income breakdown for the partner" do
          expect(cfe_result.partner_gross_income_breakdown[:state_benefits][:monthly_equivalents][:all_sources]).to eq 86.67
        end
      end

      describe "gross_income_summary" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the gross income summary for the client" do
            expect(cfe_result.gross_income_summary(partner:)[:total_gross_income]).to be_zero
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the gross income summary for the partner" do
            expect(cfe_result.gross_income_summary(partner:)[:total_gross_income]).to eq 150.0
          end
        end
      end

      describe "total_gross_income_assessed" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the total gross income for the client" do
            expect(cfe_result.total_gross_income_assessed(partner:)).to be_zero
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the total gross income for the partner" do
            expect(cfe_result.total_gross_income_assessed(partner:)).to eq 150.0
          end
        end
      end

      describe "total_disposable_income_assessed" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the total disposable income for the client only" do
            expect(cfe_result.total_disposable_income_assessed(partner:)).to be_zero
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the total disposable income for the client and the partner" do
            expect(cfe_result.total_disposable_income_assessed(partner:)).to eq 2577.11
          end
        end
      end

      describe "total_disposable_income_summary" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the disposable income summary for the client" do
            expect(cfe_result.disposable_income_summary(partner:)[:total_disposable_income]).to be_zero
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the disposable income summary for the partner" do
            expect(cfe_result.disposable_income_summary(partner:)[:total_disposable_income]).to eq 2577.11
          end
        end
      end

      describe "disposable_income_breakdown" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the disposable income breakdown for the client" do
            expect(cfe_result.disposable_income_breakdown(partner:)[:monthly_equivalents][:all_sources][:rent_or_mortgage]).to eq 125.0
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the disposable income breakdown for the partner" do
            expect(cfe_result.disposable_income_breakdown(partner:)[:monthly_equivalents][:all_sources][:rent_or_mortgage]).to eq 400
          end
        end
      end

      # EMPLOYMENT

      describe "employment_income" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the employment income for the client" do
            expect(cfe_result.employment_income(partner:)[:gross_income]).to eq 2143.97
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the employment income for the partner" do
            expect(cfe_result.employment_income(partner:)[:gross_income]).to eq 2229.17
          end
        end
      end

      describe "enployment_income_gross_income" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the employment income for the client" do
            expect(cfe_result.employment_income_gross_income(partner:)).to eq 2143.97
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the employment income for the partner" do
            expect(cfe_result.employment_income_gross_income(partner:)).to eq 2229.17
          end
        end
      end

      describe "employment_income_benefits_in_kind" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the benefits in kind for the client" do
            expect(cfe_result.employment_income_benefits_in_kind(partner:)).to eq 16.60
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the benefits in kind for the partner" do
            expect(cfe_result.employment_income_benefits_in_kind(partner:)).to be_zero
          end
        end
      end

      describe "employment_income_tax" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the employemnt income tax for the client" do
            expect(cfe_result.employment_income_tax(partner:)).to eq(-204.15)
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the employment income tax for the partner" do
            expect(cfe_result.employment_income_tax(partner:)).to eq(-235.2)
          end
        end
      end

      describe "employment_income_national_insurance" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the employemnt income national_insurance for the client" do
            expect(cfe_result.employment_income_national_insurance(partner:)).to eq(-161.64)
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the employment income national_insurance for the partner" do
            expect(cfe_result.employment_income_national_insurance(partner:)).to eq(-171.86)
          end
        end
      end

      describe "employment_income_fixed_employment_deduction" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the employemnt income fixed_employment_deduction for the client" do
            expect(cfe_result.employment_income_fixed_employment_deduction(partner:)).to eq(-45.0)
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the employment income fixed_employment_deduction for the partner" do
            expect(cfe_result.employment_income_fixed_employment_deduction(partner:)).to eq(-45.0)
          end
        end
      end

      describe "employment_income_net_employment_income" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the employemnt income net_employment_income for the client" do
            expect(cfe_result.employment_income_net_employment_income(partner:)).to eq 1778.18
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the employment income net_employment_income for the partner" do
            expect(cfe_result.employment_income_net_employment_income(partner:)).to eq 1777.11
          end
        end
      end

      describe "partner_jobs" do
        it "returns the jobs for the partner" do
          expect(cfe_result.partner_jobs[0][:name]).to eq "Job 1"
          expect(cfe_result.partner_jobs[0][:payments].length).to eq 2
        end
      end

      describe "partner_jobs?" do
        context "when the partner has jobs" do
          it "returns true" do
            expect(cfe_result.partner_jobs?).to be true
          end
        end

        context "when the partner does not have jobs" do
          let(:cfe_result) { create(:cfe_v6_result, :without_partner_jobs) }

          it "returns false" do
            expect(cfe_result.partner_jobs?).to be false
          end
        end
      end

      # MONTHLY INCOME EQUIVALENTS

      describe "monthly_income_equivalents" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the expected values" do
            expect(cfe_result.monthly_state_benefits(partner:)).to eq 75.0
            expect(cfe_result.mei_friends_or_family(partner:)).to be_zero
            expect(cfe_result.mei_maintenance_in(partner:)).to be_zero
            expect(cfe_result.mei_property_or_lodger(partner:)).to be_zero
            expect(cfe_result.mei_student_loan(partner:)).to be_zero
            expect(cfe_result.mei_pension(partner:)).to be_zero
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the expected values" do
            expect(cfe_result.monthly_state_benefits(partner:)).to eq 86.67
            expect(cfe_result.mei_friends_or_family(partner:)).to eq 166.67
            expect(cfe_result.mei_maintenance_in(partner:)).to eq 21.0
            expect(cfe_result.mei_property_or_lodger(partner:)).to eq 200.0
            expect(cfe_result.mei_student_loan(partner:)).to eq 100.0
            expect(cfe_result.mei_pension(partner:)).to eq 30.0
            expect(cfe_result.total_monthly_income_including_employment_income(partner:)).to eq 5052.48
          end
        end
      end

      describe "total_monthly_income" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the total monthly income for the client" do
            expect(cfe_result.total_monthly_income(partner:)).to eq 75.0
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the total monthly income for the partner" do
            expect(cfe_result.total_monthly_income(partner:).round(2)).to eq 604.34
          end
        end
      end

      describe "total_monthly_income_including_employment_income" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the total monthly income including employment income for the client only" do
            expect(cfe_result.total_monthly_income_including_employment_income(partner:)).to eq 2218.97
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the total monthly income including employment income for both the client and partner combined" do
            client_monthly_income = cfe_result.total_monthly_income(partner: false)
            client_employment_income = cfe_result.employment_income_gross_income(partner: false)
            partner_monthly_income = cfe_result.total_monthly_income(partner: true)
            partner_employment_income = cfe_result.employment_income_gross_income(partner: true)
            expected_total = client_monthly_income + client_employment_income + partner_monthly_income + partner_employment_income
            expect(cfe_result.total_monthly_income_including_employment_income(partner:).round(2)).to eq expected_total
          end
        end
      end

      # MONTHLY OUTGOING EQUIVALENTS

      describe "monthly_outgoing_equivalents" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the expected values" do
            expect(cfe_result.moe_childcare(partner:)).to be_zero
            expect(cfe_result.moe_housing(partner:)).to eq 125.0
            expect(cfe_result.moe_maintenance_out(partner:)).to be_zero
            expect(cfe_result.moe_legal_aid(partner:)).to eq 100.0
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the expected values" do
            expect(cfe_result.moe_childcare(partner:)).to eq 30.0
            expect(cfe_result.moe_housing(partner:)).to eq 400.0
            expect(cfe_result.moe_maintenance_out(partner:)).to eq 50.0
            expect(cfe_result.moe_legal_aid(partner:)).to be_zero
          end
        end
      end

      describe "total_monthly_outgoings" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the total monthly outgoings for the client" do
            expect(cfe_result.total_monthly_outgoings(partner:)).to eq 225.0
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the total monthly outgoings for the partner" do
            expect(cfe_result.total_monthly_outgoings(partner:)).to eq 480.0
          end
        end
      end

      describe "total_monthly_outgoings_including_employment_outgoings" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the total monthly outgoings including employment outgoings for the client only" do
            expect(cfe_result.total_monthly_outgoings_including_tax_and_ni(partner:)).to eq 590.79
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns the total monthly outgoings including employment outgoings for both the client and partner combined" do
            client_tax_and_ni = cfe_result.employment_income_tax(partner: false) + cfe_result.employment_income_national_insurance(partner: false)
            client_total_outgoings = cfe_result.total_monthly_outgoings(partner: false) - client_tax_and_ni
            partner_tax_and_ni = cfe_result.employment_income_tax(partner: true) + cfe_result.employment_income_national_insurance(partner: true)
            partner_total_outgoings = cfe_result.total_monthly_outgoings(partner: true) - partner_tax_and_ni
            expected_total = client_total_outgoings + partner_total_outgoings
            expect(cfe_result.total_monthly_outgoings_including_tax_and_ni(partner:)).to eq expected_total
          end
        end
      end

      # DEDUCTIONS

      describe "partner_allowance" do
        it "returns the partner allowance" do
          expect(cfe_result.partner_allowance).to eq(211.32)
        end
      end

      describe "total_deductions" do
        it "returns the total deductions amount" do
          expected_amount = cfe_result.dependants_allowance + cfe_result.disregarded_state_benefits + cfe_result.partner_allowance
          expect(cfe_result.total_deductions).to eq expected_amount
        end
      end

      describe "total_deductions_including_fixed_employment_allowance" do
        it "returns the deductions including the fixed employment allowance" do
          expect(cfe_result.total_deductions_including_fixed_employment_allowance).to eq 301.32
        end
      end

      # CAPITAL

      describe "capital_summary" do
        context "with partner set to false" do
          let(:partner) { false }

          it "returns the total monthly outgoings including employment outgoings for the client only" do
            expect(cfe_result.capital_summary(partner:)[:total_liquid]).to eq 12.0
          end
        end

        context "with partner set to true" do
          let(:partner) { true }

          it "returns total deductions including fixed employment allowance" do
            expect(cfe_result.capital_summary(partner:)[:total_liquid]).to eq 500.0
          end
        end
      end

      describe "partner_capital" do
        it "returns the partner capital" do
          expect(cfe_result.partner_capital).not_to be_nil
        end
      end

      describe "partner_capital?" do
        it "returns true" do
          expect(cfe_result.partner_capital?).to be true
        end
      end

      describe "current_accounts" do
        it "returns the sum of all current accounts" do
          expect(cfe_result.current_accounts).to eq 601.0
        end
      end

      describe "savings_accounts" do
        it "returns the sum of all savings accounts" do
          expect(cfe_result.savings_accounts).to eq 301.0
        end
      end

      describe "liquid_capital_items" do
        let(:client_current_account) { { description: "Current accounts", value: 1.0 } }
        let(:partner_current_account) { { description: "Partner current accounts", value: 400.0 } }

        it "returns the liquid capital items for client and partner" do
          expect(client_current_account.in?(cfe_result.liquid_capital_items)).to be true
          expect(partner_current_account.in?(cfe_result.liquid_capital_items)).to be true
        end
      end

      describe "total_savings" do
        it "returns the total savings for the client and partner" do
          expect(cfe_result.total_savings).to eq 512.0
        end
      end

      describe "total_capital" do
        it "returns the total capital amount for client and partner" do
          expect(cfe_result.total_capital).to eq 644.0
        end
      end

      describe "total_capital_before_pensioner_disregard" do
        it "returns the total capital amount before pensioner disregard" do
          expect(cfe_result.total_capital_before_pensioner_disregard).to eq 644.0
        end
      end

      describe "total_disposable_capital" do
        it "returns the total disposable capital amount" do
          expect(cfe_result.total_disposable_capital).to eq 644.0
        end
      end
    end
  end
end
