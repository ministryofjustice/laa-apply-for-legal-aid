require 'rails_helper'

module CCMS
  RSpec.describe ManualReviewDeterminer do
    let(:setting) { Setting.setting }
    let(:cfe_submission) { create :cfe_submission, legal_aid_application: legal_aid_application }

    subject { described_class.call(legal_aid_application) }

    describe '.call' do
      context 'cfe result v2' do
        context 'assessment not yet carried out on legal aid application' do
          let(:legal_aid_application) { create :legal_aid_application }
          it 'raises an error' do
            expect { subject }.to raise_error RuntimeError, 'Unable to determine whether Manual review is required before means assessment'
          end
        end

        context 'manual review setting true' do
          before { setting.update! manually_review_all_cases: true }

          context 'passported, no contrib, no_restrictions' do
            let(:legal_aid_application) { create :legal_aid_application, :with_positive_benefit_check_result }
            let!(:cfe_result) { create :cfe_v2_result, submission: cfe_submission }

            it 'returns false' do
              expect(subject).to be false
            end
          end

          context 'non-passported, no contrib' do
            let(:legal_aid_application) { create :legal_aid_application, :with_negative_benefit_check_result }
            let!(:cfe_result) { create :cfe_v2_result, submission: cfe_submission }

            it 'returns true' do
              expect(subject).to be true
            end
          end
        end

        context 'manual review setting false' do
          before { setting.update! manually_review_all_cases: false }

          context 'passported' do
            let(:legal_aid_application) { create :legal_aid_application, :with_positive_benefit_check_result, has_restrictions: true }

            context 'contribution' do
              let!(:cfe_result) { create :cfe_v2_result, :with_capital_contribution_required, submission: cfe_submission }

              it 'returns true' do
                expect(subject).to be true
              end
            end

            context 'no contribution' do
              let!(:cfe_result) { create :cfe_v2_result, submission: cfe_submission }

              context 'restrictions' do
                it 'returns false' do
                  expect(subject).to be true
                end
              end

              context 'no restrictions' do
                before { legal_aid_application.update! has_restrictions: false }

                it 'returns false' do
                  expect(subject).to be false
                end
              end
            end
          end

          context 'non-passported' do
            let(:legal_aid_application) { create :legal_aid_application, :with_negative_benefit_check_result, has_restrictions: true }

            context 'contribution' do
              let!(:cfe_result) { create :cfe_v2_result, :with_capital_contribution_required, submission: cfe_submission }

              it 'returns true' do
                expect(subject).to be true
              end
            end

            context 'no contribution' do
              let!(:cfe_result) { create :cfe_v2_result, submission: cfe_submission }

              context 'restrictions' do
                it 'returns false' do
                  expect(subject).to be true
                end
              end

              context 'no restrictions' do
                before { legal_aid_application.update! has_restrictions: false }

                it 'returns false' do
                  expect(subject).to be false
                end
              end
            end
          end
        end
      end

      context 'cfe result v3' do
        context 'assessment not yet carried out on legal aid application' do
          let(:legal_aid_application) { create :legal_aid_application }
          it 'raises an error' do
            expect { subject }.to raise_error RuntimeError, 'Unable to determine whether Manual review is required before means assessment'
          end
        end

        context 'manual review setting true' do
          before { setting.update! manually_review_all_cases: true }

          context 'passported, no contrib, no_restrictions' do
            let(:legal_aid_application) { create :legal_aid_application, :with_positive_benefit_check_result }
            let!(:cfe_result) { create :cfe_v3_result, submission: cfe_submission }

            it 'returns false' do
              expect(subject).to be false
            end
          end

          context 'non-passported, no contrib' do
            let(:legal_aid_application) { create :legal_aid_application, :with_negative_benefit_check_result }
            let!(:cfe_result) { create :cfe_v3_result, submission: cfe_submission }

            it 'returns true' do
              expect(subject).to be true
            end
          end
        end

        context 'manual review setting false' do
          before { setting.update! manually_review_all_cases: false }

          context 'passported' do
            let(:legal_aid_application) { create :legal_aid_application, :with_positive_benefit_check_result, has_restrictions: true }

            context 'contribution' do
              let!(:cfe_result) { create :cfe_v3_result, :with_capital_contribution_required, submission: cfe_submission }

              it 'returns true' do
                expect(subject).to be true
              end
            end

            context 'no contribution' do
              let!(:cfe_result) { create :cfe_v3_result, submission: cfe_submission }

              context 'restrictions' do
                it 'returns false' do
                  expect(subject).to be true
                end
              end

              context 'no restrictions' do
                before { legal_aid_application.update! has_restrictions: false }

                it 'returns false' do
                  expect(subject).to be false
                end
              end
            end
          end

          context 'non-passported' do
            let(:legal_aid_application) { create :legal_aid_application, :with_negative_benefit_check_result, has_restrictions: true }

            context 'contribution' do
              let!(:cfe_result) { create :cfe_v3_result, :with_capital_contribution_required, submission: cfe_submission }

              it 'returns true' do
                expect(subject).to be true
              end
            end

            context 'no contribution' do
              let!(:cfe_result) { create :cfe_v3_result, submission: cfe_submission }

              context 'restrictions' do
                it 'returns false' do
                  expect(subject).to be true
                end
              end

              context 'no restrictions' do
                before { legal_aid_application.update! has_restrictions: false }

                it 'returns false' do
                  expect(subject).to be false
                end
              end
            end
          end
        end
      end
    end
  end
end
