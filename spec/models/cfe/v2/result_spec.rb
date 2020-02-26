require 'rails_helper'

module CFE
  module V2
    RSpec.describe Result, type: :model do
      let(:eligible_result) { create :cfe_v2_result }
      let(:not_eligible_result) { create :cfe_v2_result, :not_eligible }
      let(:contribution_required_result) { create :cfe_v2_result, :contribution_required }
      let(:no_additional_properties) { create :cfe_v2_result, :no_additional_properties }
      let(:additional_property) { create :cfe_v2_result, :with_additional_properties }
      let(:no_vehicles) { create :cfe_v2_result, :no_vehicles }

      describe '#overview' do
        context 'applicant is eligible' do
          it 'returns assessment result' do
            expect(eligible_result.overview).to eq 'eligible'
          end
        end

        context 'applicant is not eligible and has restrictions' do
          it 'returns manual_check_required' do
            expect(contribution_required_result.capital_contribution_required?).to be true
            expect(contribution_required_result.overview).to eq 'manual_check_required'
          end
        end
      end

      describe '#overview' do
        it 'returns manual_check_required' do
          expect(not_eligible_result.overview).to eq 'not_eligible'
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
          expect(contribution_required_result.capital_contribution).to eq 6552.05
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

      #  Are the next 2 tests testing the correct thing? Currently checks that an array contains items, what if there are no items?
      describe 'non_liquid_capital_items' do
        it 'returns the description and value for first item in non liquid items array' do
          expect(eligible_result.non_liquid_capital_items.first[:description]).to be_a String
          expect(eligible_result.non_liquid_capital_items.first[:value].to_d).to eq 3902.92
        end
      end

      describe 'liquid_capital_items' do
        it 'returns the description and value for first item in liquid items array' do
          expect(eligible_result.liquid_capital_items.first[:description]).to be_a String
          expect(eligible_result.liquid_capital_items.first[:value].to_d).to eq 6692.12
        end
      end

      describe 'total_property' do
        it 'returns the assessed value for total property' do
          expect(eligible_result.total_property).to eq 1134.00
        end
      end

      describe 'total_savings' do
        it 'returns the assessed value for liquid assets' do
          expect(eligible_result.total_savings).to eq 5649.13
        end
      end

      describe 'total_other_assets' do
        it 'returns the assessed value for non liquid assets' do
          expect(eligible_result.total_other_assets).to eq 3902.92
        end
      end

      ################################################################
      # VEHICLES                                                     #
      ################################################################

      describe 'vehicle' do
        it 'returns a vehicle' do
          expect(eligible_result.vehicle).to be_kind_of(Hash)
          expect(eligible_result.vehicle[:value].to_d).to eq 1784.61
        end
      end

      describe 'vehicles?' do
        context 'vehicle(s) exist' do
          it 'returns a boolean response if vehicles exist' do
            expect(eligible_result.vehicles?).to be true
          end

          context 'vehicles dont exist'
          it 'returns a boolean response if vehicles exist' do
            expect(no_vehicles.vehicles?).to be false
          end
        end
      end

      describe 'vehicle_value' do
        it 'returns the assessed value for applicants vehicle' do
          expect(eligible_result.vehicle_value).to eq 1784.61
        end
      end

      describe 'vehicle_loan_amount_outstanding' do
        it 'returns the loan value outstanding on applicants vehicle' do
          expect(eligible_result.vehicle_loan_amount_outstanding).to eq 3225.77
        end
      end

      describe 'vehicle_disregard' do
        it 'returns the vehicle disregard for applicants vehicle ' do
          expect(eligible_result.vehicle_disregard).to eq 1784.61
        end
      end

      describe 'vehicle_assessed_amount' do
        it 'returns the assessed value for the applicants vehicle' do
          expect(eligible_result.vehicle_assessed_amount).to eq 0.0
        end
      end

      describe 'total_vehicles' do
        it 'returns the assessed value for all applicants vehicle(s)' do
          expect(eligible_result.total_vehicles).to eq 0.0
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

      describe 'monthly_other_income' do
        it 'returns the assessed montly other income for the applicant' do
          expect(eligible_result.monthly_other_income).to eq 75
        end
      end

      ################################################################
      #  MAIN HOME                                                   #
      ################################################################

      describe 'main_home_value' do
        it 'returns the assessed value for the main home' do
          expect(eligible_result.main_home_value).to eq 5985.82
        end
      end

      describe 'main_home_outstanding_mortgage' do
        it 'returns the assessed value for the main home' do
          expect(eligible_result.main_home_outstanding_mortgage).to eq(-7201.44)
        end
      end

      describe 'main_home_transaction_allowance' do
        it 'returns the assessed value for the main home' do
          expect(eligible_result.main_home_transaction_allowance).to eq(-179.57)
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
      #  OUTGOINGS                                                   #
      ################################################################

      describe 'housing_costs' do
        it 'returns the housing costs as a hash' do
          expect(eligible_result.housing_costs).to include(:amount)
          expect(eligible_result.housing_costs).to include(:payment_date)
        end
      end

      describe 'childcare_costs' do
        it 'returns the childcare costs as a hash' do
          expect(eligible_result.childcare_costs).to be_kind_of(Hash)
          expect(eligible_result.childcare_costs).to include(:amount)
          expect(eligible_result.childcare_costs).to include(:payment_date)
        end
      end

      describe 'maintenance_costs' do
        it 'returns the maintenance costs as a hash' do
          expect(eligible_result.maintenance_costs).to be_kind_of(Hash)
          expect(eligible_result.maintenance_costs).to include(:amount)
          expect(eligible_result.maintenance_costs).to include(:payment_date)
        end
      end

      ################################################################
      #  TOTALS                                                      #
      ################################################################

      describe 'pensioner_capital_disregard' do
        it 'returns the total pension disregard' do
          expect(eligible_result.pensioner_capital_disregard).to eq 0.0
        end
      end

      describe 'total_capital_before_pensioner_disregard' do
        it 'returns total capital before pension disregard' do
          expect(eligible_result.total_capital_before_pensioner_disregard).to eq 10_686.05
        end
      end

      describe 'total_disposable_capital' do
        it 'returns total disposable capital' do
          expect(eligible_result.total_disposable_capital).to eq 10_686.05
        end
      end
    end
  end
end
