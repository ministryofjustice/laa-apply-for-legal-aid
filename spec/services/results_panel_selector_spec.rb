require 'rails_helper'

RSpec.describe ResultsPanelSelector do
  before { ResultsPanelDecisionsPopulator.call }

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

      context 'invalid ResultsPanelDecision' do
        let(:cfe_result) { double CFE::V3::Result, overview: 'xxxx' }

        it 'raises' do
          expect { described_class.call(legal_aid_application) }.to raise_error ActiveRecord::RecordNotFound, "Couldn't find ResultsPanelDecision"
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

      context 'extra_employment_information free text entered' do
        before do
          allow(legal_aid_application).to receive(:extra_employment_information?).and_return(true)
        end

        context 'eligible no restrictions no policy disregards' do
          let(:cfe_result) { double CFE::V4::Result, overview: 'eligible' }

          it 'returns the eligible manual check employment partial' do
            expect(described_class.call(legal_aid_application)).to eq 'shared/assessment_results/eligible_manual_check_employment'
          end
        end

        context 'income contribution' do
          let(:cfe_result) { double CFE::V3::Result, overview: 'income_contribution_required' }

          context 'no restrictions no policy disregards' do
            it 'returns the manual check employment partial' do
              expect(described_class.call(legal_aid_application)).to eq 'shared/assessment_results/manual_check_employment'
            end
          end

          context 'no restrictions with policy disregards' do
            before do
              allow(legal_aid_application).to receive(:policy_disregards?).and_return(true)
            end

            it 'returns the manual check employment with disregards partial' do
              expect(described_class.call(legal_aid_application)).to eq 'shared/assessment_results/manual_check_disregards_employment'
            end
          end

          context 'with restrictions no policy disregards' do
            before do
              allow(legal_aid_application).to receive(:has_restrictions?).and_return(true)
            end

            it 'returns the manual check employment with restrictions partial' do
              expect(described_class.call(legal_aid_application)).to eq 'shared/assessment_results/manual_check_restrictions_employment'
            end
          end

          context 'with restrictions and with policy disregards' do
            before do
              allow(legal_aid_application).to receive(:policy_disregards?).and_return(true)
              allow(legal_aid_application).to receive(:has_restrictions?).and_return(true)
            end

            it 'returns the manual check employment with disregards with restrictions partial' do
              expect(described_class.call(legal_aid_application)).to eq 'shared/assessment_results/manual_check_disregards_restrictions_employment'
            end
          end
        end
      end
    end
  end
end
