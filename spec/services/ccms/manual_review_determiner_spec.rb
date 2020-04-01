require 'rails_helper'

module CCMS
  RSpec.describe ManualReviewDeterminer do
    let(:setting) { Setting.setting }

    subject { described_class.call(legal_aid_application) }

    describe '.call' do
      context 'assessment not yet carried out on legal aid application' do
        let(:legal_aid_application) { create :legal_aid_application }
        it 'raises an error' do
          expect { subject }.to raise_error RuntimeError, 'Unable to determine whether Manual review is required before means assessment'
        end
      end

      context 'manual review setting true' do
        let(:cfe_result) { create :cfe_v2_result }
        let(:legal_aid_application) { cfe_result.legal_aid_application }

        before { setting.update! manually_review_all_cases: true }

        it 'returns true' do
          allow_any_instance_of(ManualReviewDeterminer).to receive(:contribution_required?).and_return(false)
          expect(subject).to be true
        end
      end

      context 'manual review setting false' do
        # Zero Capital/Zero contribution/No restrictions = AUTOMATED
        # Zero Capital/Zero contribution/Restrictions apply = AUTOMATED
        # >0 Capital/Zero contribution/Restrictions apply = AUTOMATED
        # >0 Capital/>0 contribution/No Restrictions = MANUAL REVIEW
        # >0 Capital/>0 contribution/Restrictions apply = MANUAL REVIEW

        before { setting.update! manually_review_all_cases: false }

        let(:legal_aid_application) { cfe_result.legal_aid_application }

        context 'when there is no_capital and no contribution required' do
          let(:cfe_result) { create :cfe_v2_result, :eligible, :no_capital }

          context 'no restrictions on assets' do
            it { is_expected.to be false }
          end

          context 'when there are restrictions on the assets' do
            before { legal_aid_application.update! has_restrictions: true }

            it { is_expected.to be false }
          end
        end

        context 'has capital' do
          let(:cfe_result) { create :cfe_v2_result, :eligible }

          context 'no contribution required, no restrictions on assets' do
            it { is_expected.to be false }
          end

          context 'contribution required' do
            let(:cfe_result) { create :cfe_v2_result, :contribution_required }

            context 'when there are no restrictions on assets' do
              it { is_expected.to be true }
            end

            context 'when there are restrictions on assets' do
              it { is_expected.to be true }
            end
          end
        end
      end
    end
  end
end
