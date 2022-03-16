require 'rails_helper'

module HMRC
  RSpec.describe Response, type: :model do
    subject(:response) { build(:hmrc_response) }

    describe 'validations' do
      subject(:valid) { response.valid? }
      it 'is valid with all valid attributes' do
        expect(valid).to be true
      end

      context 'when the use case is not valid for apply' do
        let(:response) { build(:hmrc_response, use_case: 'three') }

        it { is_expected.to be false }
      end
    end

    describe '.use_case_for' do
      context 'there are application id does not exist' do
        it 'returns nil' do
          expect(described_class.use_case_one_for(SecureRandom.uuid)).to be_nil
        end
      end

      context 'there is only one use case one record with the specified application id' do
        let!(:response1) { create :hmrc_response, :use_case_one }
        let!(:response_uc2) { create :hmrc_response, :use_case_two, legal_aid_application_id: response1.legal_aid_application_id }
        let!(:response2) { create :hmrc_response, :use_case_one }

        it 'returns the record for the application we specify' do
          expect(described_class.use_case_one_for(response1.legal_aid_application_id)).to eq response1
        end
      end

      context 'there are multiple use case one records with the specified application id' do
        let!(:response1) { create :hmrc_response, :use_case_one, created_at: 5.minutes.ago }
        let!(:response_uc2) { create :hmrc_response, :use_case_two, legal_aid_application_id: response1.legal_aid_application_id }
        let!(:response1_last) { create :hmrc_response, :use_case_one, legal_aid_application_id: response1.legal_aid_application_id }
        let!(:response2) { create :hmrc_response, :use_case_one }

        it 'returns the last created use case one record for the specified application id' do
          expect(described_class.use_case_one_for(response1.legal_aid_application_id)).to eq response1_last
        end
      end
    end

    describe 'employment_income?' do
      context 'when there is no hmrc data' do
        let(:response) { create :hmrc_response }

        it 'returns false' do
          expect(response.employment_income?).to eq false
        end
      end

      context 'when the hmrc data does not contain employment income data' do
        let(:response) { create :hmrc_response }
        let(:response_data_with_no_employment_income) do
          { 'submission' => 'f3730ebf-4b56-4bc1-b419-417bdf2ce9d2',
            'status' => 'completed',
            'data' =>
             [{ 'correlation_id' => 'f3730ebf-4b56-4bc1-b419-417bdf2ce9d2', 'use_case' => 'use_case_one' },
              { 'individuals/matching/individual' => { 'firstName' => 'tesdt', 'lastName' => 'test', 'nino' => 'XX123456X', 'dateOfBirth' => '1970-01-01' } },
              { 'income/paye/paye' => { 'income' => [] } }] }
        end

        before { response.response = response_data_with_no_employment_income }
        it 'returns false' do
          expect(response.employment_income?).to eq false
        end
      end

      context 'when the hmrc data contains employment income data' do
        let(:response) { create :hmrc_response, :use_case_one }

        it 'returns true' do
          expect(response.employment_income?).to eq true
        end
      end
    end
  end
end
