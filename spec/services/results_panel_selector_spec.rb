require 'rails_helper'

RSpec.describe ResultsPanelSelector do
  let(:legal_aid_application) { create :legal_aid_application }

  before { allow(legal_aid_application).to receive(:cfe_result).and_return(cfe_result) }

  describe '.call' do
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
        expect { described_class.call(legal_aid_application) }.to raise_error KeyError, 'key not found: :xxxx_no_restrictions_no_disregards'
      end
    end
  end
end
