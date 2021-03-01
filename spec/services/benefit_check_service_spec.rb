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

    context 'when the call is successful', vcr: { cassette_name: 'benefit_check_service/successful_call' } do
      it 'returns the right parameters' do
        result = subject.call
        expect(result[:benefit_checker_status]).to eq('Yes')
        expect(result[:original_client_ref]).not_to be_empty
        expect(result[:confirmation_ref]).not_to be_empty
      end

      it 'sends the right parameters' do
        expect_any_instance_of(Savon::Client)
          .to receive(:call)
          .with(:check, expected_params)
          .and_call_original

        subject.call
      end

      context 'when the last name is not in upper case' do
        let(:last_name) { ' walker ' }

        it 'normalizes the last name' do
          result = subject.call
          expect(result[:benefit_checker_status]).to eq('Yes')
        end

        it 'sends the right parameters' do
          expect_any_instance_of(Savon::Client)
            .to receive(:call)
            .with(:check, expected_params)
            .and_call_original

          subject.call
        end
      end
    end

    context 'calling API raises a Savon::SOAPFault error', vcr: { cassette_name: 'benefit_check_service/service_error' } do
      let(:last_name) { 'SERVICEEXCEPTION' }

      it 'captures error' do
        expect(Sentry).to receive(:capture_exception).with(message_contains('Service unavailable'))
        subject.call
      end

      it 'returns false' do
        expect(subject.call).to eq false
      end
    end

    context 'calling API raises an unhandled error or StandardError' do
      before do
        allow_any_instance_of(Savon::Client)
          .to receive(:call)
          .with(:check, expected_params)
          .and_raise(StandardError.new('fake error'))
      end

      it 'captures error' do
        expect(Sentry).to receive(:capture_exception).with(message_contains('fake error'))
        subject.call
      end

      it 'captures StandardError' do
        expect(Sentry).to receive(:capture_exception).with(instance_of(StandardError))
        subject.call
      end

      it 'returns false' do
        expect(subject.call).to eq false
      end
    end

    context 'when the API times out' do
      before do
        savon_client = double(:savon_client)
        allow(savon_client).to receive(:call).and_raise(Net::ReadTimeout)
        allow(subject).to receive(:soap_client).and_return(savon_client)
      end

      it 'captures error and returns false' do
        expect(Sentry).to receive(:capture_exception).with(Net::ReadTimeout)
        subject.call
      end

      it 'returns false' do
        expect(subject.call).to eq false
      end
    end

    context 'when some credentials are missing', vcr: { cassette_name: 'benefit_check_service/missing_credential' } do
      before do
        allow(Rails.configuration.x.benefit_check).to receive(:client_org_id).and_return('')
      end

      it 'captures error' do
        expect(Sentry).to receive(:capture_exception).with(message_contains('Invalid request credentials'))
        subject.call
      end

      it 'returns false' do
        expect(subject.call).to eq false
      end
    end
  end

  describe '.call' do
    describe 'behaviour without mock' do
      before do
        stub_const('BenefitCheckService::USE_MOCK', false)
        allow_any_instance_of(described_class).to receive(:call).and_return(:foo)
      end

      it 'calls an instance call method' do
        expect(described_class.call(application)).to eq(:foo)
      end
    end

    describe 'behaviour with mock' do
      before { stub_const('BenefitCheckService::USE_MOCK', true) }

      it 'returns the right parameters' do
        result = described_class.call(application)
        expect(result[:benefit_checker_status]).to eq('Yes')
        expect(result[:confirmation_ref]).to match('mocked:')
      end

      context 'with matching data' do
        let(:date_of_birth) { '1955/01/11'.to_date }
        let(:national_insurance_number) { 'ZZ123456A' }

        it 'returns true' do
          result = described_class.call(application)
          expect(result[:benefit_checker_status]).to eq('No')
          expect(result[:confirmation_ref]).to match('mocked:')
        end
      end
    end
  end
end
