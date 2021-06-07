require 'rails_helper'

RSpec.describe 'cfe_result version 4 factory' do
  let(:assessment) { cfe_result.result_hash[:assessment] }
  let(:applicant) { assessment[:applicant] }
  let(:gross_income) { assessment[:gross_income] }
  let(:disposable_income) { assessment[:disposable_income] }
  let(:capital) { assessment[:capital] }
  let(:result_summary) { cfe_result.result_hash[:result_summary] }
  let(:overall_result) { result_summary[:overall_result] }
  let(:overall_result_proceeding_types) { overall_result[:proceeding_types] }
  let(:capital_summary) { result_summary[:capital] }
  let(:disposable_income_summary) { result_summary[:disposable_income] }
  let(:gross_income_summary) { result_summary[:gross_income] }
  let(:matter_types) { overall_result[:matter_types] }

  RSpec.shared_examples 'has the correct structure for v4' do
    it 'has the required top level keys' do
      expect(cfe_result.result_hash.keys).to match_array %i[version timestamp success result_summary assessment]
    end

    it 'has required keys in result summary' do
      expect(result_summary.keys).to match_array %i[overall_result gross_income disposable_income capital]
    end

    it 'has required keys in overall_result' do
      expect(overall_result.keys).to match_array %i[result
                                                    capital_contribution
                                                    income_contribution
                                                    matter_types
                                                    proceeding_types]
    end

    context 'within result_summary' do
      context 'within overall_result' do
        it 'has required keys in matter_types' do
          expect(matter_types.first.keys).to match_array %i[matter_type result]
        end

        it 'has required keys in proceeding_types' do
          expect(overall_result_proceeding_types.first.keys).to match_array %i[ccms_code result]
        end
      end

      context 'within gross_income' do
        it 'has required keys' do
          expect(gross_income_summary.keys).to match_array %i[total_gross_income proceeding_types]
        end

        context 'within proceeding_types' do
          let(:proceeding_types) { gross_income_summary[:proceeding_types].first }

          it 'has required keys' do
            expect(proceeding_types.keys).to match_array %i[ccms_code upper_threshold result]
          end
        end
      end

      context 'within disposable_income' do
        it 'has required keys' do
          expect(disposable_income_summary.keys).to match_array %i[dependant_allowance gross_housing_costs housing_benefit net_housing_costs maintenance_allowance
                                                                   total_outgoings_and_allowances total_disposable_income income_contribution proceeding_types]
        end

        context 'within proceeding_types' do
          let(:proceeding_types) { disposable_income_summary[:proceeding_types].first }

          it 'has required keys' do
            expect(proceeding_types.keys).to match_array %i[ccms_code upper_threshold lower_threshold result]
          end
        end
      end

      context 'within capital' do
        it 'has required keys' do
          expect(capital_summary.keys).to match_array %i[total_liquid total_non_liquid total_vehicle total_property total_mortgage_allowance total_capital
                                                         pensioner_capital_disregard capital_contribution assessed_capital proceeding_types]
        end

        context 'within proceeding_types' do
          let(:proceeding_types) { capital_summary[:proceeding_types].first }

          it 'has required keys' do
            expect(proceeding_types.keys).to match_array %i[ccms_code upper_threshold lower_threshold result]
          end
        end
      end
    end

    context 'within assessment' do
      it 'has required keys' do
        expect(assessment.keys).to match_array %i[id
                                                  client_reference_id
                                                  submission_date
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
        expect(gross_income.keys).to match_array %i[irregular_income
                                                    state_benefits
                                                    other_income]
      end

      it 'has required keys in disposable income' do
        expect(disposable_income.keys).to match_array %i[monthly_equivalents
                                                         childcare_allowance
                                                         deductions]
      end

      it 'has the right keys in capital' do
        expect(capital.keys).to match_array %i[capital_items]
      end

      it 'has the right keys in capital items' do
        capital_items = capital[:capital_items]
        expect(capital_items.keys).to match_array %i[liquid non_liquid vehicles properties]
      end
    end
  end

  describe 'with no traits' do
    let(:cfe_result) { create :cfe_v4_result }

    include_examples 'has the correct structure for v4'

    it 'has no contributions' do
      expect(cfe_result.assessment_result).to eq 'eligible'
      expect(cfe_result.capital_contribution).to be_zero
      expect(cfe_result.income_contribution).to be_zero
    end
  end

  describe 'trait :eligible' do
    let(:cfe_result) { create :cfe_v4_result, :eligible }

    include_examples 'has the correct structure for v4'

    it 'has no contributions' do
      expect(cfe_result.assessment_result).to eq 'eligible'
      expect(cfe_result.capital_contribution).to be_zero
      expect(cfe_result.income_contribution).to be_zero
    end
  end

  describe 'trait :not_eligible' do
    let(:cfe_result) { create :cfe_v4_result, :not_eligible }

    include_examples 'has the correct structure for v4'

    it 'is not eligible with no contributions' do
      expect(cfe_result.assessment_result).to eq 'not_eligible'
      expect(cfe_result.capital_contribution).to be_zero
      expect(cfe_result.income_contribution).to be_zero
    end
  end

  describe 'no capital' do
    let(:cfe_result) { create :cfe_v4_result, :no_capital }

    include_examples 'has the correct structure for v4'

    it 'all capital items are zero' do
      expect(cfe_result.assessment_result).to eq 'eligible'
      expect(cfe_result.capital_contribution).to be_zero
      expect(cfe_result.income_contribution).to be_zero
    end
  end

  describe 'trait :with_capital_contribution_required' do
    let(:cfe_result) { create :cfe_v4_result, :with_capital_contribution_required }

    include_examples 'has the correct structure for v4'

    it 'is eligible with a contribution' do
      expect(cfe_result.assessment_result).to eq 'contribution_required'
      expect(cfe_result.capital_contribution).not_to be_zero
      expect(cfe_result.income_contribution).to be_zero
    end
  end

  describe 'trait :no_additional_properties' do
    let(:cfe_result) { create :cfe_v4_result, :no_additional_properties }

    include_examples 'has the correct structure for v4'

    it 'is eligible' do
      expect(cfe_result.assessment_result).to eq 'eligible'
      expect(cfe_result.capital_contribution).to be_zero
      expect(cfe_result.income_contribution).to be_zero
    end

    it 'has no additional properties' do
      expect(cfe_result.additional_properties).to be_empty
    end
  end

  describe 'trait :with_additional_properties' do
    let(:cfe_result) { create :cfe_v4_result, :with_additional_properties }

    include_examples 'has the correct structure for v4'

    it 'is eligible' do
      expect(cfe_result.assessment_result).to eq 'eligible'
      expect(cfe_result.capital_contribution).to be_zero
      expect(cfe_result.income_contribution).to be_zero
    end

    it 'has additional properties' do
      expect(cfe_result.additional_properties).not_to be_empty
    end
  end

  describe 'trait :with_no_vehicles' do
    let(:cfe_result) { create :cfe_v4_result, :with_no_vehicles }

    include_examples 'has the correct structure for v4'

    it 'is eligible' do
      expect(cfe_result.assessment_result).to eq 'eligible'
      expect(cfe_result.capital_contribution).to be_zero
      expect(cfe_result.income_contribution).to be_zero
    end

    it 'has no vehicles' do
      expect(cfe_result.vehicles).to be_empty
    end
  end

  describe 'trait: with_maintenance_received' do
    let(:cfe_result) { create :cfe_v4_result, :with_maintenance_received }

    include_examples 'has the correct structure for v4'

    it 'is eligible' do
      expect(cfe_result.assessment_result).to eq 'eligible'
      expect(cfe_result.capital_contribution).to be_zero
      expect(cfe_result.income_contribution).to be_zero
    end
  end

  describe 'trait :with_mortgage_costs' do
    let(:cfe_result) { create :cfe_v4_result, :with_mortgage_costs }

    include_examples 'has the correct structure for v4'

    it 'is eligible' do
      expect(cfe_result.assessment_result).to eq 'eligible'
      expect(cfe_result.capital_contribution).to be_zero
      expect(cfe_result.income_contribution).to be_zero
    end

    it 'has mortgage_costs' do
      expect(cfe_result.mortgage_per_month).to eq 120.0
    end
  end

  describe 'trait :with_income_contribution_required' do
    let(:cfe_result) { create :cfe_v4_result, :with_income_contribution_required }

    include_examples 'has the correct structure for v4'

    it 'requires a contribution' do
      expect(cfe_result.assessment_result).to eq 'contribution_required'
      expect(cfe_result.capital_contribution).to be_zero
      expect(cfe_result.income_contribution).not_to be_zero
    end
  end

  describe 'trait :with_capital_and_income_contributions_required' do
    let(:cfe_result) { create :cfe_v4_result, :with_capital_and_income_contributions_required }

    include_examples 'has the correct structure for v4'
    it 'requires both contributions' do
      expect(cfe_result.assessment_result).to eq 'contribution_required'
      expect(cfe_result.capital_contribution).not_to be_zero
      expect(cfe_result.income_contribution).not_to be_zero
    end
  end

  describe 'trait :with_total_deductions' do
    let(:cfe_result) { create :cfe_v4_result, :with_total_deductions }

    include_examples 'has the correct structure for v4'
    it 'has total deductions' do
      expect(cfe_result.total_deductions).not_to be_zero
    end
  end

  describe 'trait :with_total_gross_income' do
    let(:cfe_result) { create :cfe_v4_result, :with_total_gross_income }

    include_examples 'has the correct structure for v4'
    it 'has total deductions' do
      expect(cfe_result.total_gross_income_assessed).not_to be_zero
    end
  end

  describe 'trait :with_mortgage_costs' do
    let(:cfe_result) { create :cfe_v4_result, :with_mortgage_costs }

    include_examples 'has the correct structure for v4'

    it 'has mortgage costs' do
      expect(cfe_result.mortgage_per_month).not_to be_zero
    end
  end

  describe 'trait :with_monthly_income_equivalents' do
    let(:cfe_result) { create :cfe_v4_result, :with_monthly_income_equivalents }

    include_examples 'has the correct structure for v4'

    it 'has correct values' do
      expect(cfe_result.mei_friends_or_family).to eq 10.0
      expect(cfe_result.mei_maintenance_in).to eq 10.0
      expect(cfe_result.mei_property_or_lodger).to eq 10.0
      expect(cfe_result.mei_pension).to eq 10.0
    end
  end

  describe 'trait :with_monthly_outgoing_equivalents' do
    let(:cfe_result) { create :cfe_v4_result, :with_monthly_outgoing_equivalents }

    include_examples 'has the correct structure for v4'

    it 'has correct values' do
      expect(cfe_result.moe_housing).to eq 10.0
      expect(cfe_result.moe_childcare).to eq 10.0
      expect(cfe_result.moe_maintenance_out).to eq 10.0
      expect(cfe_result.moe_legal_aid).to eq 10.0
    end
  end
end
