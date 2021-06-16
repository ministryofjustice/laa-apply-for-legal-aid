require 'rails_helper'

RSpec.describe ResultsPanelSelector do
  let(:legal_aid_application) { create :legal_aid_application }

  before { allow(legal_aid_application).to receive(:cfe_result).and_return(cfe_result) }

  describe '.call' do
    context 'V3 results' do
      context 'eligible no restrictions no policy disregards' do
        let(:cfe_result) { double CFE::V3::Result, overview: 'eligible' }

        it 'returns the eligible partial name' do
          expect(described_class.call(legal_aid_application)).to eq 'shared/assessment_results/eligible'
        end
      end

      context 'income_contribution_with no restrictions but with disregards' do
        let(:cfe_result) { double CFE::V3::Result, overview: 'income_contribution_required' }

        before do
          allow(legal_aid_application).to receive(:has_restrictions?).and_return(false)
          allow(legal_aid_application).to receive(:policy_disregards?).and_return(true)
        end

        it 'returns the income_contribution name' do
          expect(described_class.call(legal_aid_application)).to eq 'shared/assessment_results/manual_check_disregards'
        end
      end

      context 'invalid decision tree key' do
        let(:cfe_result) { double CFE::V3::Result, overview: 'xxxx' }

        it 'raises' do
          expect { described_class.call(legal_aid_application) }.to raise_error KeyError, 'key not found: :xxxx'
        end
      end
    end

    context 'V4 results' do
      context 'eligible no restrictions no policy disregards' do
        let(:cfe_result) { double CFE::V4::Result, overview: 'eligible' }

        it 'returns the eligible partial name' do
          expect(described_class.call(legal_aid_application)).to eq 'shared/assessment_results/eligible'
        end
      end

      context 'partially_eligible with income_contribution no restrictions or disregards' do
        let(:cfe_result) { create :cfe_v4_result, :partially_eligible_with_income_contribution_required }

        before do
          allow(legal_aid_application).to receive(:has_restrictions?).and_return(false)
          allow(legal_aid_application).to receive(:policy_disregards?).and_return(false)
        end

        it 'returns the correct income specific partial' do
          expect(described_class.call(legal_aid_application)).to eq 'shared/assessment_results/partially_eligible_income'
        end
      end

      context 'partially_eligible with capital_contribution no restrictions or disregards' do
        let(:cfe_result) { create :cfe_v4_result, :partially_eligible_with_capital_contribution_required }

        before do
          allow(legal_aid_application).to receive(:has_restrictions?).and_return(false)
          allow(legal_aid_application).to receive(:policy_disregards?).and_return(false)
        end

        it 'returns the correct capital specific partial' do
          expect(described_class.call(legal_aid_application)).to eq 'shared/assessment_results/partially_eligible_capital'
        end
      end
    end
  end
end
