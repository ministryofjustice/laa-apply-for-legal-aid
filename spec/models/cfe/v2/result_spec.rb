require "rails_helper"

module CFE
  module V2
    RSpec.describe Result do
      let(:eligible_result) { create(:cfe_v2_result) }
      let(:not_eligible_result) { create(:cfe_v2_result, :not_eligible) }
      let(:contribution_required_result) { create(:cfe_v2_result, :with_capital_contribution_required) }
      let(:income_contribution_required_result) { create(:cfe_v2_result, :with_income_contribution_required) }
      let(:no_additional_properties) { create(:cfe_v2_result, :no_additional_properties) }
      let(:additional_property) { create(:cfe_v2_result, :with_additional_properties) }
      let(:no_vehicles) { create(:cfe_v2_result, :no_vehicles) }
      let(:with_maintenance) { create(:cfe_v2_result, :with_maintenance_received) }
      let(:with_student_finance) { create(:cfe_v2_result, :with_student_finance_received) }
      let(:no_mortgage) { create(:cfe_v2_result, :with_no_mortgage_costs) }
      let(:legal_aid_application) { create(:legal_aid_application, :with_restrictions, :with_cfe_v2_result) }
      let(:contribution_and_restriction_result) { create(:cfe_v2_result, :with_capital_contribution_required, submission: cfe_submission) }
      let(:cfe_submission) { create(:cfe_submission, legal_aid_application:) }
      let(:manual_review_determiner) { CCMS::ManualReviewDeterminer.new(application) }

      describe "#overview" do
        subject(:overview) { cfe_result.overview }

        let(:application) { cfe_result.legal_aid_application }

        context "when manual check not required" do
          before { allow(manual_review_determiner).to receive(:manual_review_required?).and_return(false) }

          context "when eligible" do
            let(:cfe_result) { create(:cfe_v2_result, :eligible) }

            it "returns eligible" do
              expect(overview).to eq "eligible"
            end
          end

          context "when not_eligible" do
            let(:cfe_result) { create(:cfe_v2_result, :not_eligible) }

            it "returns not_eligible" do
              expect(overview).to eq "ineligible"
            end
          end

          context "with capital_contribution_required" do
            let(:cfe_result) { create(:cfe_v2_result, :with_capital_contribution_required) }

            it "returns capital_contribution_required" do
              expect(overview).to eq "capital_contribution_required"
            end
          end

          context "with income_contribution_required" do
            let(:cfe_result) { create(:cfe_v2_result, :with_income_contribution_required) }

            it "returns income_contribution_required" do
              expect(overview).to eq "income_contribution_required"
            end
          end

          context "with capital_and_income_contribution_required" do
            let(:cfe_result) { create(:cfe_v2_result, :with_capital_and_income_contributions_required) }

            it "returns capital_and_income_contribution_required" do
              expect(overview).to eq "capital_and_income_contribution_required"
            end
          end
        end

        context "when manual check IS required and restrictions do not exist" do
          before { allow(manual_review_determiner).to receive(:manual_review_required?).and_return(true) }

          context "and eligible" do
            let(:cfe_result) { create(:cfe_v2_result, :eligible) }

            it "returns eligible" do
              expect(overview).to eq "eligible"
            end
          end

          context "and not_eligible" do
            let(:cfe_result) { create(:cfe_v2_result, :not_eligible) }

            it "returns not_eligible" do
              expect(overview).to eq "ineligible"
            end
          end

          context "with capital_contribution_required" do
            let(:cfe_result) { create(:cfe_v2_result, :with_capital_contribution_required) }

            it "returns capital_contribution_required" do
              expect(overview).to eq "capital_contribution_required"
            end
          end

          context "with income_contribution_required" do
            let(:cfe_result) { create(:cfe_v2_result, :with_income_contribution_required) }

            it "returns income_contribution_required" do
              expect(overview).to eq "income_contribution_required"
            end
          end

          context "with capital_and_income_contribution_required" do
            let(:cfe_result) { create(:cfe_v2_result, :with_capital_and_income_contributions_required) }

            it "returns capital_and_income_contribution_required" do
              expect(overview).to eq "capital_and_income_contribution_required"
            end
          end
        end

        context "when manual check IS required and restrictions exist" do
          before do
            allow(manual_review_determiner).to receive(:manual_review_required?).and_return(true)
            application.has_restrictions = true
          end

          context "and eligible" do
            let(:cfe_result) { create(:cfe_v2_result, :eligible) }

            it "returns manual_check_required" do
              expect(overview).to eq "manual_check_required"
            end
          end

          context "and not_eligible" do
            let(:cfe_result) { create(:cfe_v2_result, :not_eligible) }

            it "returns manual_check_required" do
              expect(overview).to eq "manual_check_required"
            end
          end

          context "when capital_contribution_required" do
            let(:cfe_result) { create(:cfe_v2_result, :with_capital_contribution_required) }

            it "returns manual_check_required" do
              expect(overview).to eq "manual_check_required"
            end
          end

          context "when income_contribution_required" do
            let(:cfe_result) { create(:cfe_v2_result, :with_income_contribution_required) }

            it "returns manual_check_required" do
              expect(overview).to eq "manual_check_required"
            end
          end

          context "when capital_and_income_contribution_required" do
            let(:cfe_result) { create(:cfe_v2_result, :with_capital_and_income_contributions_required) }

            it "returns manual_check_required" do
              expect(overview).to eq "manual_check_required"
            end
          end
        end
      end

      describe "#assessment_result" do
        context "when eligible" do
          it "returns eligible" do
            expect(eligible_result.assessment_result).to eq "eligible"
          end
        end

        context "when not_eligible" do
          it "returns not_eligible" do
            expect(not_eligible_result.assessment_result).to eq "ineligible"
          end
        end

        context "when contribution_required" do
          it "returns contribution_required" do
            expect(contribution_required_result.assessment_result).to eq "contribution_required"
          end
        end
      end

      describe "#capital_contribution" do
        it "returns the value of the capital contribution" do
          expect(contribution_required_result.capital_contribution).to eq 465.66
        end
      end

      context "with disposable income" do
        let(:result) { income_contribution_required_result }

        describe "#income_contribution" do
          it "returns required contribution" do
            expect(result.income_contribution).to eq 366.82
          end
        end

        describe "#total_disposable_income_asssessed" do
          it "returns the value" do
            expect(result.total_disposable_income_assessed).to eq "0.0"
          end
        end

        describe "#total_gross_income_assessed" do
          it "returns the value" do
            expect(result.total_gross_income_assessed).to eq "150.0"
          end
        end

        describe "#gross_income_upper_threshold" do
          it "returns the value" do
            expect(result.gross_income_upper_threshold).to eq "999999999999.0"
          end
        end

        describe "#disposable_income_lower_threshold" do
          it "returns the value" do
            expect(result.disposable_income_lower_threshold).to eq "315.0"
          end
        end

        describe "#disposable_income_upper_threshold" do
          it "returns the value" do
            expect(result.disposable_income_upper_threshold).to eq "733.0"
          end
        end

        describe "#monthly_state_benefits" do
          it "returns the value" do
            expect(result.monthly_state_benefits).to eq "75.0"
            expect(result.total_gross_income).to eq 150.0
            expect(result.total_capital).to eq "9552.05"
          end
        end
      end

      describe "eligible?" do
        context "when returns true" do
          it "returns boolean response for eligible" do
            expect(eligible_result.eligible?).to be true
          end
        end

        context "when returns false" do
          it "returns false response for eligible" do
            expect(not_eligible_result.eligible?).to be false
          end
        end
      end

      describe "#version" do
        subject(:version) { eligible_result.version }

        it { expect(version).to be 2 }
      end

      describe "capital_contribution_required?" do
        context "when contribution not required" do
          it "returns false for capital_contribution_required" do
            expect(eligible_result.capital_contribution_required?).to be false
          end
        end

        context "when contribution is required" do
          it "returns true for capital_contribution_required" do
            expect(contribution_required_result.capital_contribution_required?).to be true
          end
        end
      end

      ################################################################
      #  CAPITAL ITEMS                                               #
      ################################################################

      #  Are the next 2 tests testing the correct thing? Currently checks that an array contains items, what if there are no items?
      describe "non_liquid_capital_items" do
        it "returns the description and value for first item in non liquid items array" do
          expect(eligible_result.non_liquid_capital_items.first[:description]).to be_a String
          expect(eligible_result.non_liquid_capital_items.first[:value].to_d).to eq 3902.92
        end
      end

      describe "liquid_capital_items" do
        it "returns the description and value for first item in liquid items array" do
          expect(eligible_result.liquid_capital_items.first[:description]).to be_a String
          expect(eligible_result.liquid_capital_items.first[:value].to_d).to eq 6692.12
        end
      end

      describe "total_property" do
        it "returns the assessed value for total property" do
          expect(eligible_result.total_property).to eq 1134.00
        end
      end

      describe "total_savings" do
        it "returns the assessed value for liquid assets" do
          expect(eligible_result.total_savings).to eq 5649.13
        end
      end

      describe "total_other_assets" do
        it "returns the assessed value for non liquid assets" do
          expect(eligible_result.total_other_assets).to eq 3902.92
        end
      end

      ################################################################
      # VEHICLES                                                     #
      ################################################################

      describe "vehicle" do
        it "returns a vehicle" do
          expect(eligible_result.vehicle).to be_a(Hash)
          expect(eligible_result.vehicle[:value].to_d).to eq 1784.61
        end
      end

      describe "vehicles?" do
        context "when vehicle(s) exist" do
          it "returns a boolean response" do
            expect(eligible_result.vehicles?).to be true
          end

          context "when vehicles do not exist"
          it "returns a boolean response" do
            expect(no_vehicles.vehicles?).to be false
          end
        end
      end

      describe "vehicle_value" do
        it "returns the assessed value for applicants vehicle" do
          expect(eligible_result.vehicle_value).to eq 1784.61
        end
      end

      describe "vehicle_loan_amount_outstanding" do
        it "returns the loan value outstanding on applicants vehicle" do
          expect(eligible_result.vehicle_loan_amount_outstanding).to eq 3225.77
        end
      end

      describe "vehicle_disregard" do
        it "returns the vehicle disregard for applicants vehicle" do
          expect(eligible_result.vehicle_disregard).to eq 1784.61
        end
      end

      describe "vehicle_assessed_amount" do
        it "returns the assessed value for the applicants vehicle" do
          expect(eligible_result.vehicle_assessed_amount).to eq 0.0
        end
      end

      describe "total_vehicles" do
        it "returns the assessed value for all applicants vehicle(s)" do
          expect(eligible_result.total_vehicles).to eq 0.0
        end
      end

      ################################################################
      #  ADDITIONAL PROPERTY                                         #
      ################################################################

      describe "#additional_property?" do
        context "when present" do
          it "returns true" do
            expect(additional_property.additional_property?).to be true
          end
        end

        context "when not present" do
          it "returns false" do
            expect(no_additional_properties.additional_property?).to be false
          end
        end

        context "when present but zero" do
          it "returns false" do
            expect(eligible_result.additional_property?).to be false
          end
        end
      end

      describe "additional_property_value" do
        it "returns the value of the first additional property" do
          expect(additional_property.additional_property_value).to eq 5_781.91
        end
      end

      describe "additional_property_transaction_allowance" do
        it "returns the transaction allowance for the first additional property" do
          expect(additional_property.additional_property_transaction_allowance).to eq(-113.46)
        end
      end

      describe "additional_property_mortgage" do
        it "returns the mortgage for the first additional property" do
          expect(additional_property.additional_property_mortgage).to eq(-8202.00)
        end
      end

      describe "additional_property_assessed_equity" do
        it "returns the assessed equity for the first additional property" do
          expect(additional_property.additional_property_assessed_equity).to eq 125.33
        end
      end

      describe "monthly_other_income" do
        it "returns the assessed montly other income for the applicant" do
          expect(eligible_result.monthly_other_income).to eq 75
        end
      end

      ################################################################
      #  MAIN HOME                                                   #
      ################################################################

      describe "main_home_value" do
        it "returns the assessed value for the main home" do
          expect(eligible_result.main_home_value).to eq 5985.82
        end
      end

      describe "main_home_outstanding_mortgage" do
        it "returns the assessed value for the main home" do
          expect(eligible_result.main_home_outstanding_mortgage).to eq(-7201.44)
        end
      end

      describe "main_home_transaction_allowance" do
        it "returns the assessed value for the main home" do
          expect(eligible_result.main_home_transaction_allowance).to eq(-179.57)
        end
      end

      describe "main_home_equity_disregard" do
        it "returns the assessed value for the main home" do
          expect(eligible_result.main_home_equity_disregard).to eq(-100_000.0)
        end
      end

      describe "main_home_assessed_equity" do
        it "returns the assessed value for the main home" do
          expect(eligible_result.main_home_assessed_equity).to eq 0.0
        end
      end

      ################################################################
      #  OUTGOINGS                                                   #
      ################################################################

      describe "housing_costs" do
        it "returns the housing costs as a hash" do
          expect(eligible_result.housing_costs).to include(:amount)
          expect(eligible_result.housing_costs).to include(:payment_date)
        end
      end

      describe "childcare_costs" do
        it "returns the childcare costs as a hash" do
          expect(eligible_result.childcare_costs).to be_a(Hash)
          expect(eligible_result.childcare_costs).to include(:amount)
          expect(eligible_result.childcare_costs).to include(:payment_date)
        end
      end

      describe "maintenance_costs" do
        it "returns the maintenance costs as a hash" do
          expect(eligible_result.maintenance_costs).to be_a(Hash)
          expect(eligible_result.maintenance_costs).to include(:amount)
          expect(eligible_result.maintenance_costs).to include(:payment_date)
        end
      end

      ################################################################
      #  DISPOSABLE INCOME                                           #
      ################################################################

      describe "maintenance_per_month" do
        context "when maintenance is received" do
          subject(:maintenance_per_month) { with_maintenance.maintenance_per_month }

          it { is_expected.to eq 150.00 }
        end

        context "when maintenance is not received" do
          subject(:maintenance_per_month) { eligible_result.maintenance_per_month }

          it { is_expected.to eq 0.00 }
        end
      end

      describe "mei_student_loan" do
        context "when student_loan is received" do
          subject(:mei_student_loan) { with_student_finance.mei_student_loan }

          it { is_expected.to eq 125.00 }
        end

        context "when student_loan is not received" do
          subject(:mei_student_loan) { eligible_result.mei_student_loan }

          it { is_expected.to eq 0.00 }
        end
      end

      describe "monthly equivalent income" do
        let(:result) { eligible_result }

        it "returns the expected values" do
          expect(result.mei_friends_or_family).to eq 50.59
          expect(result.mei_maintenance_in).to eq 54.17
          expect(result.mei_property_or_lodger).to eq 450.0
          expect(result.mei_pension).to eq 82.52
          expect(result.total_monthly_income).to eq 712.28
          expect(result.total_monthly_income_including_employment_income).to eq 712.28
        end
      end

      describe "monthly outgoing equivalents" do
        let(:result) { eligible_result }

        it "returns the expected values" do
          expect(result.moe_housing).to eq 15.75
          expect(result.moe_childcare).to be_zero
          expect(result.moe_maintenance_out).to eq 3.64
          expect(result.moe_legal_aid).to eq 7.0
          expect(result.total_monthly_outgoings).to eq 26.39
          expect(result.total_monthly_outgoings_including_tax_and_ni).to eq 26.39
        end
      end

      describe "deductions" do
        let(:result) { eligible_result }

        it "returns the expected values" do
          expect(result.dependants_allowance).to eq 291.86
          expect(result.disregarded_state_benefits).to eq 1500.0
          expect(result.total_deductions).to eq 1791.86
          expect(result.total_deductions_including_fixed_employment_allowance).to eq 1791.86
        end
      end

      ################################################################
      #  TOTALS                                                      #
      ################################################################

      describe "mortgage per month" do
        context "when mortgage is paid" do
          it "returns the value of mortgage per month" do
            expect(eligible_result.mortgage_per_month).to eq 125.0
          end
        end

        context "when no mortgage is paid" do
          it "returns the value of mortgage per month" do
            expect(no_mortgage.mortgage_per_month).to eq 0.0
          end
        end
      end

      describe "pensioner_capital_disregard" do
        it "returns the total pension disregard" do
          expect(eligible_result.pensioner_capital_disregard).to eq 0.0
        end
      end

      describe "total_capital_before_pensioner_disregard" do
        it "returns total capital before pension disregard" do
          expect(eligible_result.total_capital_before_pensioner_disregard).to eq 10_686.05
        end
      end

      describe "total_disposable_capital" do
        it "returns total disposable capital" do
          expect(eligible_result.total_disposable_capital).to eq 10_686.05
        end
      end

      ################################################################
      #  REMARKS                                                     #
      ################################################################

      describe "remarks" do
        it "returns a CFE::Remarks object" do
          expect(eligible_result.remarks).to be_instance_of(CFE::Remarks)
        end

        it "instantiates the Remarks class with the remarks part of the hash" do
          expect(CFE::Remarks).to receive(:new).with({})
          eligible_result.remarks
        end
      end
    end
  end
end
