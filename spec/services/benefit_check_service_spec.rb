require 'rails_helper'

RSpec.describe BenefitCheckService do
  let(:last_name) { 'WALKER' }
  let(:date_of_birth) { '1980/01/10'.to_date }
  let(:national_insurance_number) { 'JA293483A' }
  let(:applicant) { create :applicant, last_name: last_name, date_of_birth: date_of_birth, national_insurance_number: national_insurance_number }
  let(:application) { create :application, applicant: applicant }

  subject { described_class.new(application) }

  describe '#check_benefits', :vcr do
    let(:expected_params) do
      hash_including(
        message: hash_including(
          clientReference: application.id,
          surname: applicant.last_name.strip.upcase,
          dateOfBirth: applicant.date_of_birth.strftime('%Y%m%d')
        )
      )
    end

    context 'when the call is successful' do
      it 'returns the right parameters' do
        result = subject.check_benefits
        expect(result[:benefit_checker_status]).to eq('Yes')
        expect(result[:original_client_ref]).not_to be_empty
        expect(result[:confirmation_ref]).not_to be_empty
      end

      it 'sends the right parameters' do
        expect_any_instance_of(Savon::Client)
          .to receive(:call)
          .with(:check, expected_params)
          .and_call_original

        subject.check_benefits
      end

      context 'when the last name is not in upper case' do
        let(:last_name) { ' walker ' }

        it 'normalizes the last name' do
          result = subject.check_benefits
          expect(result[:benefit_checker_status]).to eq('Yes')
        end

        it 'sends the right parameters' do
          expect_any_instance_of(Savon::Client)
            .to receive(:call)
            .with(:check, expected_params)
            .and_call_original

          subject.check_benefits
        end
      end
    end

    context 'when the API raises an error' do
      let(:last_name) { 'SERVICEEXCEPTION' }

      it 'raises an error' do
        expect { subject.check_benefits }.to raise_error(Savon::SOAPFault)
      end
    end

    context 'when some credentials are missing' do
      before do
        allow(Rails.configuration.x.benefit_check).to receive(:client_org_id).and_return('')
      end

      it 'raises an error' do
        expect { subject.check_benefits }.to raise_error(Savon::SOAPFault)
      end
    end
  end
end
