require 'rails_helper'

module CFE
  module V4
    RSpec.describe Result, type: :model do
      let(:eligible_result) { create :cfe_v4_result }
      let(:not_eligible_result) { create :cfe_v4_result, :not_eligible }
      let(:contribution_required_result) { create :cfe_v4_result, :with_capital_contribution_required }
      let(:no_additional_properties) { create :cfe_v4_result, :no_additional_properties }
      let(:additional_property) { create :cfe_v4_result, :with_additional_properties }
      let(:with_no_vehicles) { create :cfe_v4_result, :with_no_vehicles }
      let(:with_maintenance) { create :cfe_v4_result, :with_maintenance_received }
      let(:with_student_finance) { create :cfe_v4_result, :with_student_finance_received }
      let(:with_total_deductions) { create :cfe_v4_result, :with_total_deductions }
      let(:with_mortgage) { create :cfe_v4_result, :with_mortgage_costs }
      let(:with_monthly_income_equivalents) { create :cfe_v4_result, :with_monthly_income_equivalents }
      let(:with_monthly_outgoing_equivalents) { create :cfe_v4_result, :with_monthly_outgoing_equivalents }
      let(:with_total_gross_income) { create :cfe_v4_result, :with_total_gross_income }
      let(:legal_aid_application) { create :legal_aid_application, :with_restrictions, :with_cfe_v4_result }
      let(:contribution_and_restriction_result) { create :cfe_v4_result, :with_capital_contribution_required, submission: cfe_submission }
      let(:cfe_submission) { create :cfe_submission, legal_aid_application: legal_aid_application }
      let(:manual_review_determiner) { CCMS::ManualReviewDeterminer.new(application) }

      describe '#overview' do
        subject { cfe_result.overview }

        let(:application) { cfe_result.legal_aid_application }

        context 'manual check not required' do
          before { allow(manual_review_determiner).to receive(:manual_review_required?).and_return(false) }

          context 'eligible' do
            let(:cfe_result) { create :cfe_v4_result, :eligible }
            it 'returns eligible' do
              expect(subject).to eq 'eligible'
            end
          end

          context 'not_eligible' do
            let(:cfe_result) { create :cfe_v4_result, :not_eligible }
            it 'returns not_eligible' do
              expect(subject).to eq 'not_eligible'
            end
          end

          context 'capital_contribution_required' do
            let(:cfe_result) { create :cfe_v4_result, :with_capital_contribution_required }
            it 'returns capital_contribution_required' do
              expect(subject).to eq 'capital_contribution_required'
            end
          end

          context 'income_contribution_required' do
            let(:cfe_result) { create :cfe_v4_result, :with_income_contribution_required }
            it 'returns income_contribution_required' do
              expect(subject).to eq 'income_contribution_required'
            end
          end

          context 'capital_and_income_contribution_required' do
            let(:cfe_result) { create :cfe_v4_result, :with_capital_and_income_contributions_required }
            it 'returns capital_and_income_contribution_required' do
              expect(subject).to eq 'capital_and_income_contribution_required'
            end
          end
        end

        context 'manual check IS required and restrictions do not exist' do
          before { allow(manual_review_determiner).to receive(:manual_review_required?).and_return(true) }

          context 'eligible' do
            let(:cfe_result) { create :cfe_v4_result, :eligible }
            it 'returns eligible' do
              expect(subject).to eq 'eligible'
            end
          end

          context 'not_eligible' do
            let(:cfe_result) { create :cfe_v4_result, :not_eligible }
            it 'returns not_eligible' do
              expect(subject).to eq 'not_eligible'
            end
          end

          context 'capital_contribution_required' do
            let(:cfe_result) { create :cfe_v4_result, :with_capital_contribution_required }
            it 'returns capital_contribution_required' do
              expect(subject).to eq 'capital_contribution_required'
            end
          end

          context 'income_contribution_required' do
            let(:cfe_result) { create :cfe_v4_result, :with_income_contribution_required }
            it 'returns income_contribution_required' do
              expect(subject).to eq 'income_contribution_required'
            end
          end

          context 'capital_and_income_contribution_required' do
            let(:cfe_result) { create :cfe_v4_result, :with_capital_and_income_contributions_required }
            it 'returns capital_and_income_contribution_required' do
              expect(subject).to eq 'capital_and_income_contribution_required'
            end
          end
        end

        context 'manual check IS required and restrictions exist' do
          before do
            allow(manual_review_determiner).to receive(:manual_review_required?).and_return(true)
            application.has_restrictions = true
          end

          context 'eligible' do
            let(:cfe_result) { create :cfe_v4_result, :eligible }
            it 'returns manual_check_required' do
              expect(subject).to eq 'manual_check_required'
            end
          end

          context 'not_eligible' do
            let(:cfe_result) { create :cfe_v4_result, :not_eligible }
            it 'returns manual_check_required' do
              expect(subject).to eq 'manual_check_required'
            end
          end

          context 'income_contribution_required' do
            let(:cfe_result) { create :cfe_v4_result, :with_income_contribution_required }
            it 'returns manual_check_required' do
              expect(subject).to eq 'manual_check_required'
            end
          end

          context 'capital_and_income_contribution_required' do
            let(:cfe_result) { create :cfe_v4_result, :with_capital_and_income_contributions_required }
            it 'returns manual_check_required' do
              expect(subject).to eq 'manual_check_required'
            end
          end
        end
      end

      describe '#assessment_result' do
        context 'eligible' do
          it 'returns eligible' do
            expect(eligible_result.assessment_result).to eq 'eligible'
          end
        end

        context 'not_eligible' do
          it 'returns not_eligible' do
            expect(not_eligible_result.assessment_result).to eq 'not_eligible'
          end
        end

        context 'contribution_required' do
          it 'returns contribution_required' do
            expect(contribution_required_result.assessment_result).to eq 'contribution_required'
          end
        end
      end

      describe '#capital_contribution' do
        it 'returns the value of the capital contribution' do
          expect(contribution_required_result.capital_contribution).to eq 465.66
        end
      end

      describe 'eligible?' do
        context 'returns true' do
          it 'returns boolean response for eligible' do
            expect(eligible_result.eligible?).to be true
          end
        end

        context 'returns false' do
          it 'returns false response for eligible' do
            expect(not_eligible_result.eligible?).to be false
          end
        end
      end

      describe '#version_4?' do
        it 'returns boolean response for cfe version check' do
          expect(eligible_result.version_4?).to be true
        end
      end

      describe 'capital_contribution_required?' do
        context 'contribution not required ' do
          it 'returns false for capital_contribution_required' do
            expect(eligible_result.capital_contribution_required?).to be false
          end
        end

        context 'contribution is required ' do
          it 'returns true for capital_contribution_required' do
            expect(contribution_required_result.capital_contribution_required?).to be true
          end
        end
      end

      ################################################################
      #  CAPITAL ITEMS                                               #
      ################################################################

      describe 'non_liquid_capital_items' do
        it 'returns the description and value for first item in non liquid items array' do
          expect(eligible_result.non_liquid_capital_items.first[:description]).to be_a String
          expect(eligible_result.non_liquid_capital_items.first[:value].to_d).to eq 12.00
        end
      end

      describe 'liquid_capital_items' do
        it 'returns the description and value for first item in liquid items array' do
          expect(eligible_result.liquid_capital_items.first[:description]).to be_a String
          expect(eligible_result.liquid_capital_items.first[:value].to_d).to eq 1.00
        end
      end

      describe 'total_property' do
        it 'returns the assessed value for total property' do
          expect(eligible_result.total_property).to eq 0.0
        end
      end

      describe 'total_capital' do
        it 'returns the assessed value for total capital' do
          expect(eligible_result.total_capital).to eq 144.0
        end
      end

      describe 'total_savings' do
        it 'returns the assessed value for liquid assets' do
          expect(eligible_result.total_savings).to eq 12.00
        end
      end

      describe 'total_other_assets' do
        it 'returns the assessed value for non liquid assets' do
          expect(eligible_result.total_other_assets).to eq 12.0
        end
      end

      ################################################################
      # VEHICLES                                                     #
      ################################################################

      describe 'vehicle' do
        it 'returns a vehicle' do
          expect(eligible_result.vehicle).to be_kind_of(Hash)
          expect(eligible_result.vehicle[:value].to_d).to eq 120.0
        end
      end

      describe 'vehicles?' do
        context 'vehicle(s) exist' do
          it 'returns a boolean response if vehicles exist' do
            expect(eligible_result.vehicles?).to be true
          end
        end
        context "vehicles don't exist" do
          it 'returns a boolean response if vehicles do not exist' do
            expect(with_no_vehicles.vehicles?).to be false
          end
        end
      end

      describe 'vehicle_value' do
        it 'returns the assessed value for applicants vehicle' do
          expect(eligible_result.vehicle_value).to eq 120.0
        end
      end

      describe 'vehicle_loan_amount_outstanding' do
        it 'returns the loan value outstanding on applicants vehicle' do
          expect(eligible_result.vehicle_loan_amount_outstanding).to eq 12.0
        end
      end

      describe 'vehicle_disregard' do
        it 'returns the vehicle disregard for applicants vehicle ' do
          expect(eligible_result.vehicle_disregard).to eq 0.0
        end
      end

      describe 'vehicle_assessed_amount' do
        it 'returns the assessed value for the applicants vehicle' do
          expect(eligible_result.vehicle_assessed_amount).to eq 120.0
        end
      end

      describe 'total_vehicles' do
        it 'returns the assessed value for all applicants vehicle(s)' do
          expect(eligible_result.total_vehicles).to eq 120.0
        end
      end

      ################################################################
      #  ADDITIONAL PROPERTY                                         #
      ################################################################

      describe '#additional_property?' do
        context 'present' do
          it 'returns true' do
            expect(additional_property.additional_property?).to be true
          end
        end

        context 'not present' do
          it 'returns false' do
            expect(no_additional_properties.additional_property?).to be false
          end
        end

        context 'present but zero' do
          it 'returns false' do
            expect(eligible_result.additional_property?).to be false
          end
        end
      end

      describe 'additional_property_value' do
        it 'returns the value of the first additional property' do
          expect(additional_property.additional_property_value).to eq 5_781.91
        end
      end

      describe 'additional_property_transaction_allowance' do
        it 'returns the transaction allowance for the first additional property' do
          expect(additional_property.additional_property_transaction_allowance).to eq(-113.46)
        end
      end

      describe 'additional_property_mortgage' do
        it 'returns the mortgage for the first additional property' do
          expect(additional_property.additional_property_mortgage).to eq(-8202.00)
        end
      end

      describe 'additional_property_assessed_equity' do
        it 'returns the assessed equity for the first additional property' do
          expect(additional_property.additional_property_assessed_equity).to eq 125.33
        end
      end

      ################################################################
      #  MAIN HOME                                                   #
      ################################################################

      describe 'main_home_value' do
        it 'returns the assessed value for the main home' do
          expect(eligible_result.main_home_value).to eq 10.0
        end
      end

      describe 'main_home_outstanding_mortgage' do
        it 'returns the assessed value for the main home' do
          expect(eligible_result.main_home_outstanding_mortgage).to eq(-20.0)
        end
      end

      describe 'main_home_transaction_allowance' do
        it 'returns the assessed value for the main home' do
          expect(eligible_result.main_home_transaction_allowance).to eq(-0.3)
        end
      end

      describe 'main_home_equity_disregard' do
        it 'returns the assessed value for the main home' do
          expect(eligible_result.main_home_equity_disregard).to eq(-100_000.0)
        end
      end

      describe 'main_home_assessed_equity' do
        it 'returns the assessed value for the main home' do
          expect(eligible_result.main_home_assessed_equity).to eq 0.0
        end
      end

      ################################################################
      #  DISPOSABLE INCOME                                           #
      ################################################################

      describe 'maintenance_per_month' do
        context 'when maintenance is received' do
          subject(:maintenance_per_month) { with_maintenance.maintenance_per_month }
          it { is_expected.to eq 150.00 }
        end

        context 'when maintenance is not received' do
          subject(:maintenance_per_month) { eligible_result.maintenance_per_month }
          it { is_expected.to eq 0.00 }
        end
      end

      describe 'mei_student_loan' do
        context 'when student_loan is received' do
          subject(:mei_student_loan) { with_student_finance.mei_student_loan }
          it { is_expected.to eq 125.00 }
        end

        context 'when student_loan is not received' do
          subject(:mei_student_loan) { eligible_result.mei_student_loan }
          it { is_expected.to eq 0.00 }
        end
      end

      ################################################################
      #  THRESHOLDS                                                  #
      ################################################################

      context 'thresholds within proceeding types' do
        context 'gross income thresholds' do
          let(:gross_income_proceeding_types) do
            [
              {
                ccms_code: 'DA006',
                upper_threshold: 999_999_999_999.0,
                result: 'pending'
              },
              {
                ccms_code: 'DA002',
                upper_threshold: 999_999_999_999.0,
                result: 'pending'
              }
            ]
          end
          describe '#gross_income_per_proceeding_types' do
            it 'returns the gross income per proceeding type' do
              expect(eligible_result.gross_income_proceeding_types).to match gross_income_proceeding_types
            end
          end
        end

        context 'disposable income thresholds' do
          let(:disposable_income_proceeding_types) do
            [
              {
                ccms_code: 'DA006',
                upper_threshold: 999_999_999_999.0,
                lower_threshold: 315.0,
                result: 'pending'
              },
              {
                ccms_code: 'DA002',
                upper_threshold: 999_999_999_999.0,
                lower_threshold: 315.0,
                result: 'pending'
              }
            ]
          end

          describe '#disposable_income_proceeding_types' do
            it 'returns the disposable income upper threshold' do
              expect(eligible_result.disposable_income_proceeding_types).to match disposable_income_proceeding_types
            end
          end
        end
      end

      ################################################################
      #  TOTALS                                                      #
      ################################################################

      describe 'mortgage per month' do
        context 'when mortgage is paid' do
          it 'returns the value of mortgage per month' do
            expect(with_mortgage.mortgage_per_month).to eq 120.0
          end
        end

        context 'when no mortgage is paid' do
          it 'returns the value of mortgage per month' do
            expect(eligible_result.mortgage_per_month).to eq 0.0
          end
        end
      end

      describe 'pensioner_capital_disregard' do
        it 'returns the total pension disregard' do
          expect(eligible_result.pensioner_capital_disregard).to eq 0.0
        end
      end

      describe 'total_capital_before_pensioner_disregard' do
        it 'returns total capital before pension disregard' do
          expect(eligible_result.total_capital_before_pensioner_disregard).to eq 144.0
        end
      end

      describe 'total_disposable_capital' do
        it 'returns total disposable capital' do
          expect(eligible_result.total_disposable_capital).to eq 144.0
        end
      end

      describe 'total_monthly_income' do
        it 'returns total monthly income' do
          expect(with_monthly_income_equivalents.total_monthly_income).to eq 40.0
        end
      end

      describe 'total_monthly_outgoings' do
        it 'returns total monthly outgoings' do
          expect(with_monthly_outgoing_equivalents.total_monthly_outgoings).to eq 40.0
        end
      end

      describe 'total_gross_income' do
        it 'returns total gross income' do
          expect(with_total_gross_income.total_gross_income).to eq 150.0
        end
      end

      describe 'total_disposable_income_assessed' do
        it 'returns total disposable income assessed' do
          expect(eligible_result.total_disposable_income_assessed).to eq 0.0
        end
      end

      describe 'total_gross_income_assessed' do
        it 'returns total gross income assessed' do
          expect(with_total_gross_income.total_gross_income_assessed).to eq 150.0
        end
      end

      describe 'total_deductions' do
        it 'returns total deductions' do
          expect(with_total_deductions.total_deductions).to eq 1300.0
        end
      end

      ################################################################
      #  REMARKS                                                     #
      ################################################################

      describe 'remarks' do
        it 'returns a CFE::Remarks object' do
          expect(eligible_result.remarks).to be_instance_of(CFE::Remarks)
        end

        it 'instantiates the Remarks class with the remarks part of the hash' do
          expect(CFE::Remarks).to receive(:new).with({})
          eligible_result.remarks
        end
      end
    end
  end
end
