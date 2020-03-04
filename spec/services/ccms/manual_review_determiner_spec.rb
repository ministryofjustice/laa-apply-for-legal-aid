require 'rails_helper'

module CCMS
  RSpec.describe ManualReviewDeterminer do
    let(:setting) { Setting.setting }

    subject { described_class.call(legal_aid_application) }

    describe '.call' do
      context 'assessment not yet carried out on legal aid application' do
        let(:legal_aid_application) { create :legal_aid_application }
        it 'raises' do
          expect { subject }.to raise_error RuntimeError, 'Unable to determine whether Manual review is required before means assessment'
        end
      end

      context 'manual review setting true' do
        let(:cfe_result) { create :cfe_v1_result }
        let(:legal_aid_application) { cfe_result.legal_aid_application }

        before { setting.update! manually_review_all_cases: true }

        it 'returns true' do
          allow_any_instance_of(ManualReviewDeterminer).to receive(:restriction_on_capital_assets?).and_return(false)
          allow_any_instance_of(ManualReviewDeterminer).to receive(:contribution_required?).and_return(false)
          expect(subject).to be true
        end
      end

      context 'manual review setting false' do
        before { setting.update! manually_review_all_cases: false }

        let(:legal_aid_application) { cfe_result.legal_aid_application }

        context 'no contribution required, no restrictions on assets' do
          let(:cfe_result) { create :cfe_v1_result, :eligible }
          it 'does not require manual review' do
            expect(subject).to be false
          end
        end

        context 'contribution required' do
          let(:cfe_result) { create :cfe_v1_result, :contribution_required }
          it 'requires manual review' do
            expect(subject).to be true
          end
        end

        context 'restriction on assets' do
          let(:cfe_result) { create :cfe_v1_result, :eligible }

          before { legal_aid_application.update! has_restrictions: true }

          it 'requires manual review' do
            expect(subject).to be true
          end
        end
      end
    end
  end
end
