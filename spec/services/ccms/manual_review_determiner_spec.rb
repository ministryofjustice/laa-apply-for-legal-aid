require 'rails_helper'

module CCMS
  RSpec.describe ManualReviewDeterminer do
    let(:setting) { Setting.setting }
    let!(:cfe_submission) { create :cfe_submission, legal_aid_application: legal_aid_application }
    let(:determiner) { described_class.new(legal_aid_application) }
    let(:legal_aid_application) { create :legal_aid_application }

    describe '#manual_review_required?' do
      subject { determiner.manual_review_required? }

      context 'assessment not yet carried out on legal aid application' do
        it 'raises an error' do
          expect { subject }.to raise_error RuntimeError, 'Unable to determine whether Manual review is required before means assessment'
        end
      end

      context 'manual review setting true' do
        before { setting.update! manually_review_all_cases: true }

        context 'no DWP override' do
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

        context 'with DWP override' do
          before { create :dwp_override, legal_aid_application: legal_aid_application }

          context 'passported, no contrib, no_restrictions' do
            let(:legal_aid_application) { create :legal_aid_application, :with_positive_benefit_check_result }
            let!(:cfe_result) { create :cfe_v3_result, submission: cfe_submission }

            it 'returns true' do
              expect(subject).to be true
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
      end

      context 'manual review setting false' do
        before { setting.update! manually_review_all_cases: false }
        context 'no DWP override' do
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

        context 'with DWP override' do
          before { create :dwp_override, legal_aid_application: legal_aid_application }
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

                it 'returns true' do
                  expect(subject).to be true
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

                it 'returns true' do
                  legal_aid_application.reload
                  expect(subject).to be true
                end
              end
            end
          end
        end
      end
    end

    describe '#review_reasons' do
      subject { determiner.review_reasons }

      let(:cfe_result) { double 'CFE Result', remarks: cfe_remarks }
      let(:cfe_remarks) { double 'CFE Remarks', review_reasons: review_reasons }
      let(:review_reasons) { %i[unknown_frequency multi_benefit] }
      let(:override_reaons) { %i[unknown_frequency multi_benefit dwp_override] }

      before { allow_any_instance_of(cfe_submission.class).to receive(:result).and_return(cfe_result) }

      context 'No DWP Override' do
        it 'just takes the review reasons from the CFE result' do
          expect(subject).to eq review_reasons
        end
      end

      context 'With DWP override' do
        before { create :dwp_override, legal_aid_application: legal_aid_application }
        it 'adds the dwp review to the cfe result reasons' do
          expect(subject).to eq override_reaons
        end
      end
    end
  end
end
