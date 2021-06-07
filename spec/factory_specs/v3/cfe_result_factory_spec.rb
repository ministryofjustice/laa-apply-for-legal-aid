require 'rails_helper'

RSpec.describe 'cfe_result factory' do
  let(:assessment) { cfe_result.result_hash[:assessment] }
  let(:applicant) { assessment[:applicant] }
  let(:gross_income) { assessment[:gross_income] }
  let(:disposable_income) { assessment[:disposable_income] }
  let(:capital) { assessment[:capital] }

  RSpec.shared_examples 'has the correct structure for v3' do
    it 'has the required top level keys' do
      expect(cfe_result.result_hash.keys).to match_array %i[version timestamp success assessment]
    end

    it 'has required keys in assessment' do
      expect(assessment.keys).to match_array %i[id
                                                client_reference_id
                                                submission_date
                                                matter_proceeding_type
                                                assessment_result
                                                applicant
                                                gross_income
                                                disposable_income
                                                capital
                                                remarks]
    end

    it 'has required keys in applicant' do
      expect(applicant.keys).to match_array %i[date_of_birth
                                               involvement_type
                                               has_partner_opponent
                                               receives_qualifying_benefit
                                               self_employed]
    end

    it 'has required keys in gross income' do
      expect(gross_income.keys).to match_array %i[summary
                                                  irregular_income
                                                  state_benefits
                                                  other_income]
    end

    it 'has required keys in gross income summary' do
      expect(gross_income[:summary].keys).to match_array %i[total_gross_income
                                                            upper_threshold
                                                            assessment_result]
    end

    it 'has required keys in gross income other income monthly equivalents' do
      expect(gross_income[:other_income][:monthly_equivalents].keys).to match_array %i[cash_transactions
                                                                                       bank_transactions
                                                                                       all_sources]
    end

    it 'has required keys in disposable income monthly equivalents' do
      expect(disposable_income[:monthly_equivalents].keys).to match_array %i[cash_transactions
                                                                             bank_transactions
                                                                             all_sources]
    end

    it 'has required keys in disposable income' do
      expect(disposable_income.keys).to match_array %i[monthly_equivalents
                                                       deductions
                                                       childcare_allowance
                                                       dependant_allowance
                                                       maintenance_allowance
                                                       gross_housing_costs
                                                       housing_benefit
                                                       net_housing_costs
                                                       total_outgoings_and_allowances
                                                       total_disposable_income
                                                       lower_threshold
                                                       upper_threshold
                                                       assessment_result
                                                       income_contribution]
    end

    it 'has the right keys in capital' do
      expect(capital.keys).to match_array %i[capital_items
                                             total_liquid
                                             total_non_liquid
                                             total_vehicle
                                             total_property
                                             total_mortgage_allowance
                                             total_capital
                                             pensioner_capital_disregard
                                             assessed_capital
                                             lower_threshold
                                             upper_threshold
                                             assessment_result
                                             capital_contribution]
    end
  end

  describe 'with no traits' do
    let(:cfe_result) { create :cfe_v3_result }

    include_examples 'has the correct structure for v3'

    it 'has no contributions' do
      expect(cfe_result.assessment_result).to eq 'eligible'
      expect(cfe_result.capital_assessment_result).to eq 'eligible'
      expect(cfe_result.income_assessment_result).to eq 'eligible'
      expect(cfe_result.capital_contribution).to be_zero
      expect(cfe_result.income_contribution).to be_zero
    end
  end

  describe 'trait :eligible' do
    let(:cfe_result) { create :cfe_v3_result, :eligible }

    include_examples 'has the correct structure for v3'

    it 'has no contributions' do
      expect(cfe_result.assessment_result).to eq 'eligible'
      expect(cfe_result.capital_assessment_result).to eq 'eligible'
      expect(cfe_result.income_assessment_result).to eq 'eligible'
      expect(cfe_result.capital_contribution).to be_zero
      expect(cfe_result.income_contribution).to be_zero
    end
  end

  describe 'trait :not_eligible' do
    let(:cfe_result) { create :cfe_v3_result, :not_eligible }

    include_examples 'has the correct structure for v3'

    it 'is not eligible with no contributions' do
      expect(cfe_result.assessment_result).to eq 'not_eligible'
      expect(cfe_result.capital_assessment_result).to eq 'not_eligible'
      expect(cfe_result.income_assessment_result).to eq 'not_eligible'
      expect(cfe_result.capital_contribution).to be_zero
      expect(cfe_result.income_contribution).to be_zero
    end
  end

  describe 'no capital' do
    let(:cfe_result) { create :cfe_v3_result, :no_capital }

    include_examples 'has the correct structure for v3'

    it 'all capital items are zero' do
      expect(cfe_result.assessment_result).to eq 'eligible'
      expect(cfe_result.capital_assessment_result).to eq 'eligible'
      expect(cfe_result.income_assessment_result).to eq 'eligible'
      expect(cfe_result.capital_contribution).to be_zero
      expect(cfe_result.income_contribution).to be_zero
    end
  end

  describe 'trait :with_capital_contribution_required' do
    let(:cfe_result) { create :cfe_v3_result, :with_capital_contribution_required }

    include_examples 'has the correct structure for v3'

    it 'is eligible with a contribution' do
      expect(cfe_result.assessment_result).to eq 'contribution_required'
      expect(cfe_result.capital_assessment_result).to eq 'contribution_required'
      expect(cfe_result.income_assessment_result).to eq 'eligible'
      expect(cfe_result.capital_contribution).not_to be_zero
      expect(cfe_result.income_contribution).to be_zero
    end
  end

  describe 'trait :no_additional_properties' do
    let(:cfe_result) { create :cfe_v3_result, :no_additional_properties }

    include_examples 'has the correct structure for v3'

    it 'is eligible' do
      expect(cfe_result.assessment_result).to eq 'eligible'
      expect(cfe_result.capital_assessment_result).to eq 'eligible'
      expect(cfe_result.income_assessment_result).to eq 'eligible'
      expect(cfe_result.capital_contribution).to be_zero
      expect(cfe_result.income_contribution).to be_zero
    end

    it 'has no additional properties' do
      expect(cfe_result.additional_properties).to be_empty
    end
  end

  describe 'trait :with_additional_properties' do
    let(:cfe_result) { create :cfe_v3_result, :with_additional_properties }

    include_examples 'has the correct structure for v3'

    it 'is eligible' do
      expect(cfe_result.assessment_result).to eq 'eligible'
      expect(cfe_result.capital_assessment_result).to eq 'eligible'
      expect(cfe_result.income_assessment_result).to eq 'eligible'
      expect(cfe_result.capital_contribution).to be_zero
      expect(cfe_result.income_contribution).to be_zero
    end

    it 'has additional properties' do
      expect(cfe_result.additional_properties).not_to be_empty
    end
  end

  describe 'trait :no_vehicles' do
    let(:cfe_result) { create :cfe_v3_result, :no_vehicles }

    include_examples 'has the correct structure for v3'

    it 'is eligible' do
      expect(cfe_result.assessment_result).to eq 'eligible'
      expect(cfe_result.capital_assessment_result).to eq 'eligible'
      expect(cfe_result.income_assessment_result).to eq 'eligible'
      expect(cfe_result.capital_contribution).to be_zero
      expect(cfe_result.income_contribution).to be_zero
    end

    it 'has no vehicles' do
      expect(cfe_result.vehicles).to be_empty
    end
  end

  describe 'trait: with_maintenance_received' do
    let(:cfe_result) { create :cfe_v3_result, :with_maintenance_received }

    include_examples 'has the correct structure for v3'

    it 'is eligible' do
      expect(cfe_result.assessment_result).to eq 'eligible'
      expect(cfe_result.capital_assessment_result).to eq 'eligible'
      expect(cfe_result.income_assessment_result).to eq 'eligible'
      expect(cfe_result.capital_contribution).to be_zero
      expect(cfe_result.income_contribution).to be_zero
    end
  end

  describe 'trait :no_mortgage_costs' do
    let(:cfe_result) { create :cfe_v3_result, :with_no_mortgage_costs }

    include_examples 'has the correct structure for v3'

    it 'is eligible' do
      expect(cfe_result.assessment_result).to eq 'eligible'
      expect(cfe_result.capital_assessment_result).to eq 'eligible'
      expect(cfe_result.income_assessment_result).to eq 'eligible'
      expect(cfe_result.capital_contribution).to be_zero
      expect(cfe_result.income_contribution).to be_zero
    end

    it 'has no_mortgage_costs' do
      expect(cfe_result.mortgage_per_month).to be_zero
    end
  end

  describe 'trait :with_income_contribution_required' do
    let(:cfe_result) { create :cfe_v3_result, :with_income_contribution_required }

    include_examples 'has the correct structure for v3'

    it 'requires a contribution' do
      expect(cfe_result.assessment_result).to eq 'contribution_required'
      expect(cfe_result.capital_assessment_result).to eq 'eligible'
      expect(cfe_result.income_assessment_result).to eq 'contribution_required'
      expect(cfe_result.capital_contribution).to be_zero
      expect(cfe_result.income_contribution).not_to be_zero
    end
  end

  describe 'trait :with_capital_and_income_contributions_required' do
    let(:cfe_result) { create :cfe_v3_result, :with_capital_and_income_contributions_required }

    include_examples 'has the correct structure for v3'
    it 'requires both contributions' do
      expect(cfe_result.assessment_result).to eq 'contribution_required'
      expect(cfe_result.capital_assessment_result).to eq 'contribution_required'
      expect(cfe_result.income_assessment_result).to eq 'contribution_required'
      expect(cfe_result.capital_contribution).not_to be_zero
      expect(cfe_result.income_contribution).not_to be_zero
    end
  end
end
