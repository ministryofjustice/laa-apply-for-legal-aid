require 'rails_helper'

module TrueLayer
  RSpec.describe IdentifyApplicant do
    let(:token) { SecureRandom.uuid }
    let(:address) { create :address }
    let(:applicant) { address.applicant }
    subject { described_class.new(token) }

    let(:user_data) do
      {
        results: [
          {
            addresses: [
              {
                address: "#{address.address_line_one} #{address.address_line_two}",
                city: address.city,
                country: 'GB',
                zip: address.postcode
              }
            ],
            emails: [applicant.email],
            full_name: "#{applicant.first_name} #{applicant.last_name}",
            phones: ['+14151234567'],
            update_timestamp: '0001-01-01T00:00:00Z'
          }
        ]
      }
    end

    let(:data) { user_data }
    let(:status) { 200 }

    def stub_request_to_return(json)
      stub_request(:get, 'https://api.truelayer.com/data/v1/info')
        .with(
          headers: {
            'Authorization' => "Bearer #{token}"
          }
        )
        .to_return(status: status, body: json, headers: {})
    end

    before do
      stub_request_to_return(data.to_json)
    end

    describe '#response' do
      it 'returns response from end point' do
        expect(subject.response).to be_success
      end

      context 'with True Layer error' do
        let(:status) { 401 }
        let(:date) { {} }

        it 'does not return success' do
          expect(subject.response).not_to be_success
        end
      end
    end

    describe '#emails' do
      it 'returns the applicant email' do
        expect(subject.emails).to eq([applicant.email])
      end
    end

    describe '#applicant' do
      it 'returns the applicant' do
        expect(subject.applicant).to eq(applicant)
      end

      context 'with True Layer error' do
        let(:status) { 401 }
        let(:date) { {} }

        it 'returns nil' do
          expect(subject.applicant).to be_nil
        end

        it 'returns an errors type' do
          subject.applicant
          expect(subject.error).to eq('TrueLayer log in failed')
        end
      end

      context 'with no match to Applicant' do
        let(:applicant) { build :applicant }

        it 'returns nil' do
          expect(subject.applicant).to be_nil
        end

        it 'returns an errors type' do
          subject.applicant
          expect(subject.error).to eq('Credentials do not match')
        end
      end
    end

    describe '#error' do
      it 'nil until something goes wrong' do
        expect(subject.error).to be_nil
      end
    end
  end
end
