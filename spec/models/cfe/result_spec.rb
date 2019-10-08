require 'rails_helper'

module CFE
  RSpec.describe Result, type: :model do
    let(:eligible_result) { create :cfe_result }
    let(:not_eligible_result) { create :cfe_result, :not_eligible }
    let(:contibution_required_result) { create :cfe_result, :contribution_required }

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
          expect(contibution_required_result.assessment_result).to eq 'contribution_required'
        end
      end
    end

    describe '#capital_contribution' do
      it 'returns the value of the capital contribution' do
        expect(contibution_required_result.capital_contribution).to eq 465.66
      end
    end
  end
end
