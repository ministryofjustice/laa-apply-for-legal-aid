require 'rails_helper'

module CFE
  module V1
    RSpec.describe Result, type: :model do
      let(:eligible_result) { create :cfe_v1_result }
      let(:not_eligible_result) { create :cfe_v1_result, :not_eligible }
      let(:contribution_required_result) { create :cfe_v1_result, :contribution_required }
      let(:contribution_and_restriction_result) { create :cfe_v1_result, :contribution_required, submission: cfe_submission }
      let(:no_additional_properties) { create :cfe_v1_result, :no_additional_properties }
      let(:additional_property) { create :cfe_v1_result, :with_additional_properties }
      let(:legal_aid_application) { create :legal_aid_application, :with_restrictions, :with_cfe_v1_result }
      let(:cfe_submission) { create :cfe_submission, legal_aid_application: legal_aid_application }

      before { Setting.destroy_all }

      describe '#overview' do
        context 'applicant is eligible' do
          before { allow(CCMS::ManualReviewDeterminer).to receive(:call).with(eligible_result.legal_aid_application).and_return(false) }
          it 'returns assessment result' do
            expect(eligible_result.overview).to eq 'eligible'
          end
        end

        context 'applicant has contribution required and no restrictions' do
          before { allow(CCMS::ManualReviewDeterminer).to receive(:call).with(contribution_required_result.legal_aid_application).and_return(false) }
          it 'returns manual_check_required' do
            expect(contribution_required_result.capital_contribution_required?).to be true
            expect(contribution_required_result.overview).to eq 'capital_contribution_required'
          end
        end
      end

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
            expect(contribution_required_result.assessment_result).to eq 'contribution_required'
          end
        end
      end

      describe '#capital_contribution' do
        it 'returns the value of the capital contribution' do
          expect(contribution_required_result.capital_contribution).to eq 465.66
        end
      end

      describe '#additional_property?' do
        context 'present' do
          it 'returns true' do
            expect(additional_property.additional_property?).to be true
          end
        end
        context 'not present' do
          it 'returns false' do
            expect(no_additional_properties.additional_property?).to be false
          end
        end
        context 'present but zero' do
          it 'returns false' do
            expect(eligible_result.additional_property?).to be false
          end
        end
      end

      describe 'additional_property_value' do
        it 'returns the value of the first additional property' do
          expect(additional_property.additional_property_value).to eq 350_255.0
        end
      end

      describe 'additional_property_transaction_allowance' do
        it 'returns the transaction allowance for the first additional property' do
          expect(additional_property.additional_property_transaction_allowance).to eq(-12_550.0)
        end
      end

      describe 'additional_property_mortgage' do
        it 'returns the mortgage for the first additional property' do
          expect(additional_property.additional_property_mortgage).to eq(-45_000.0)
        end
      end

      describe 'additional_property_assessed_equity' do
        it 'returns the assessed equity for the first additional property' do
          expect(additional_property.additional_property_assessed_equity).to eq 224_000.0
        end
      end
    end
  end
end
