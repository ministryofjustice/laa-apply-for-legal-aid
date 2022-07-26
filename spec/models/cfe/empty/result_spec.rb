require "rails_helper"

module CFE
  module Empty
    RSpec.describe Result, type: :model do
      let(:empty_cfe_result) { create :cfe_empty_result }
      let(:legal_aid_application) { create :legal_aid_application, :with_cfe_empty_result }
      let(:manual_review_determiner) { CCMS::ManualReviewDeterminer.new(application) }

      describe "#assessment_result" do
        context "when no call is made to cfe and an empty result is created" do
          it "returns no_assessment" do
            expect(empty_cfe_result.assessment_result).to eq "no_assessment"
          end
        end
      end

      describe "eligible?" do
        it "returns boolean response for eligible" do
          expect(empty_cfe_result.eligible?).to be false
        end
      end

      describe "#version" do
        subject(:version) { empty_cfe_result.version }

        it { expect(version).to be 0 }
      end

      describe "#version_4?" do
        it "returns boolean response for cfe version check" do
          expect(empty_cfe_result.version_4?).to be false
        end
      end

      describe "liquid_capital_items" do
        it "returns the description and value for first item in liquid items array" do
          expect(empty_cfe_result.liquid_capital_items.first[:description]).to be_a String
          expect(empty_cfe_result.liquid_capital_items.first[:value].to_d).to eq 0.0
        end
      end

      describe "total_property" do
        it "returns the assessed value for total property" do
          expect(empty_cfe_result.total_property).to eq 0.0
        end
      end

      describe "total_capital" do
        it "returns the assessed value for total capital" do
          expect(empty_cfe_result.total_capital).to eq 0.0
        end
      end

      describe "total_savings" do
        it "returns the assessed value for liquid assets" do
          expect(empty_cfe_result.total_savings).to eq 0.0
        end
      end

      describe "total_other_assets" do
        it "returns the assessed value for non liquid assets" do
          expect(empty_cfe_result.total_other_assets).to eq 0.0
        end
      end

      ################################################################
      # VEHICLES                                                     #
      ################################################################

      describe "vehicles?" do
        context "when vehicle(s) do not exist" do
          it "returns a boolean response if vehicles do not exist" do
            expect(empty_cfe_result.vehicles?).to be false
          end
        end
      end

      describe "total_vehicles" do
        it "returns the assessed value for all applicants vehicle(s)" do
          expect(empty_cfe_result.total_vehicles).to eq 0.0
        end
      end

      ################################################################
      #  ADDITIONAL PROPERTY                                         #
      ################################################################

      describe "#additional_property?" do
        context "when not present" do
          it "returns false" do
            expect(empty_cfe_result.additional_property?).to be false
          end
        end
      end

      describe "additional_property_value" do
        it "returns the value of the first additional property" do
          expect(empty_cfe_result.additional_property_value).to eq 0.0
        end
      end

      describe "additional_property_transaction_allowance" do
        it "returns the transaction allowance for the first additional property" do
          expect(empty_cfe_result.additional_property_transaction_allowance).to eq 0.0
        end
      end

      describe "additional_property_mortgage" do
        it "returns the mortgage for the first additional property" do
          expect(empty_cfe_result.additional_property_mortgage).to eq 0.0
        end
      end

      describe "additional_property_assessed_equity" do
        it "returns the assessed equity for the first additional property" do
          expect(empty_cfe_result.additional_property_assessed_equity).to eq 0.0
        end
      end

      ################################################################
      #  MAIN HOME                                                   #
      ################################################################

      describe "main_home_value" do
        it "returns the assessed value for the main home" do
          expect(empty_cfe_result.main_home_value).to eq 0.0
        end
      end

      describe "main_home_outstanding_mortgage" do
        it "returns the assessed value for the main home" do
          expect(empty_cfe_result.main_home_outstanding_mortgage).to eq 0.0
        end
      end

      describe "main_home_transaction_allowance" do
        it "returns the assessed value for the main home" do
          expect(empty_cfe_result.main_home_transaction_allowance).to eq 0.0
        end
      end

      describe "main_home_equity_disregard" do
        it "returns the assessed value for the main home" do
          expect(empty_cfe_result.main_home_equity_disregard).to eq(-100_000.0)
        end
      end

      describe "main_home_assessed_equity" do
        it "returns the assessed value for the main home" do
          expect(empty_cfe_result.main_home_assessed_equity).to eq 0.0
        end
      end

      ################################################################
      #  DISPOSABLE INCOME                                           #
      ################################################################

      describe "maintenance_per_month" do
        context "when maintenance is not received" do
          subject(:maintenance_per_month) { empty_cfe_result.maintenance_per_month }

          it { is_expected.to eq 0.00 }
        end
      end

      describe "mei_student_loan" do
        context "when student_loan is not received" do
          subject(:mei_student_loan) { empty_cfe_result.mei_student_loan }

          it { is_expected.to eq 0.0 }
        end
      end

      ################################################################
      #  THRESHOLDS                                                  #
      ################################################################

      describe "thresholds" do
        describe "#gross_income_upper_threshold" do
          context "with only domestic abuse" do
            it "returns N/a" do
              expect(empty_cfe_result.gross_income_upper_threshold).to eq "N/a"
            end
          end
        end

        describe "#disposable_income_upper_threshold" do
          context "with only domestic abuse" do
            it "returns N/a" do
              expect(empty_cfe_result.disposable_income_upper_threshold).to eq "N/a"
            end
          end
        end

        describe "#disposable_income_lower_threshold" do
          context "with only domestic abuse" do
            it "returns N/a" do
              expect(empty_cfe_result.disposable_income_lower_threshold).to eq 315.0
            end
          end
        end
      end

      context "with thresholds within proceeding types" do
        context "with gross income thresholds" do
          let(:gross_income_proceeding_types) do
            [
              {
                ccms_code: "DA001",
                upper_threshold: 999_999_999_999.0,
                result: "no_assessment",
              },
            ]
          end

          describe "#gross_income_per_proceeding_types" do
            it "returns the gross income per proceeding type" do
              expect(empty_cfe_result.gross_income_proceeding_types).to match gross_income_proceeding_types
            end
          end
        end

        context "with disposable income thresholds" do
          let(:disposable_income_proceeding_types) do
            [
              {
                ccms_code: "DA001",
                upper_threshold: 999_999_999_999.0,
                lower_threshold: 315.0,
                result: "no_assessment",
              },
            ]
          end

          describe "#disposable_income_proceeding_types" do
            it "returns the disposable income upper threshold" do
              expect(empty_cfe_result.disposable_income_proceeding_types).to match disposable_income_proceeding_types
            end
          end
        end
      end

      ################################################################
      #  TOTALS                                                      #
      ################################################################

      describe "mortgage per month" do
        context "when mortgage is paid" do
          it "returns the value of mortgage per month" do
            expect(empty_cfe_result.mortgage_per_month).to eq 0.0
          end
        end
      end

      describe "pensioner_capital_disregard" do
        it "returns the total pension disregard" do
          expect(empty_cfe_result.pensioner_capital_disregard).to eq 0.0
        end
      end

      describe "total_capital_before_pensioner_disregard" do
        it "returns total capital before pension disregard" do
          expect(empty_cfe_result.total_capital_before_pensioner_disregard).to eq 0.0
        end
      end

      describe "total_disposable_capital" do
        it "returns total disposable capital" do
          expect(empty_cfe_result.total_disposable_capital).to eq 0.0
        end
      end

      describe "total_monthly_income" do
        it "returns total monthly income" do
          expect(empty_cfe_result.total_monthly_income).to eq 0.0
        end
      end

      describe "total_monthly_income_including_employment_income" do
        it "returns total monthly income including employment income" do
          expect(empty_cfe_result.total_monthly_income_including_employment_income).to eq 0.0
        end
      end

      describe "total_monthly_outgoings" do
        it "returns total monthly outgoings" do
          expect(empty_cfe_result.total_monthly_outgoings).to eq 0.0
        end
      end

      describe "total_monthly_outgoings_including_tax_and_ni" do
        it "returns total monthly outgoings including tax and ni" do
          expect(empty_cfe_result.total_monthly_outgoings_including_tax_and_ni).to eq 0.0
        end
      end

      describe "total_gross_income" do
        it "returns zero for total gross income" do
          expect(empty_cfe_result.total_gross_income).to eq 0.0
        end
      end

      describe "capital_contribution" do
        it "returns zero for capital_contribution" do
          expect(empty_cfe_result.capital_contribution).to eq 0.0
        end
      end

      describe "capital_contribution_required?" do
        it "returns false for capital_contribution_required" do
          expect(empty_cfe_result.capital_contribution_required?).to be false
        end
      end

      describe "income_assessment_result" do
        it "returns no_assessment for income_assessment_result" do
          expect(empty_cfe_result.income_assessment_result).to eq "no_assessment"
        end
      end

      describe "capital_assessment_result" do
        it "returns no_assessment for capital_assessment_result" do
          expect(empty_cfe_result.capital_assessment_result).to eq "no_assessment"
        end
      end

      describe "income_contribution" do
        it "returns zero for income_contribution" do
          expect(empty_cfe_result.income_contribution).to eq 0.0
        end
      end

      describe "total_disposable_income_assessed" do
        it "returns total disposable income assessed" do
          expect(empty_cfe_result.total_disposable_income_assessed).to eq 0.0
        end
      end

      describe "total_gross_income_assessed" do
        it "returns total gross income assessed" do
          expect(empty_cfe_result.total_gross_income_assessed).to eq 0.0
        end
      end

      describe "total_deductions" do
        it "returns total deductions" do
          expect(empty_cfe_result.total_deductions).to eq 0.0
        end
      end

      describe "total_deductions_including_fixed_employment_allowance" do
        it "returns total deductions including_employment restrictions" do
          expect(empty_cfe_result.total_deductions_including_fixed_employment_allowance).to eq 45.0
        end
      end

      ################################################################
      #  REMARKS                                                     #
      ################################################################

      describe "remarks" do
        it "returns a CFE::Remarks object" do
          expect(empty_cfe_result.remarks).to be_instance_of(CFE::Remarks)
        end

        it "instantiates the Remarks class with the remarks part of the hash" do
          expect(CFE::Remarks).to receive(:new).with({})
          empty_cfe_result.remarks
        end
      end
    end
  end
end
