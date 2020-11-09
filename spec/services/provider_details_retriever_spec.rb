require 'rails_helper'

RSpec.describe ProviderDetailsRetriever do
  let(:api_url) { 'https://ccms-pda.stg.legalservices.gov.uk/api/providerDetails' }
  let(:provider) { create :provider }
  let(:username) { provider.username }

  subject { described_class.call(username) }

  before do
    allow(Rails.configuration.x.provider_details).to receive(:url).and_return(api_url)
  end

  describe '.call' do
    shared_examples_for 'get response from API' do
      it 'returns the expected data structure' do
        expected_keys = %i[providerFirmId contactUserId contacts providerOffices feeEarners]
        expect(subject.keys).to match_array(expected_keys)

        expected_office_keys = %i[id name]
        expect(subject[:providerOffices][0].keys).to match_array(expected_office_keys)
      end
    end

    context 'error calling api' do
      it 'raises ApiError' do
        allow(Net::HTTP).to receive(:get_response).and_raise(RuntimeError, 'Something went wrong')
        expect {
          subject
        }.to raise_error(ProviderDetailsRetriever::ApiError, 'Provider details error: RuntimeError :: Something went wrong')
      end
    end

    context 'with real API', vcr: { cassette_name: 'provider_details_api' } do
      let(:provider) { create :provider, :with_provider_details_api_username }
      let(:escaped_username) { CGI.escape(provider.username) }

      it_behaves_like 'get response from API'

      it 'encode properly the username' do
        expect(URI).to receive(:parse).at_least(:once).with(/#{escaped_username}/).and_call_original
        subject
      end

      context 'username with space', vcr: { cassette_name: 'encoded_provider_details_api' } do
        let(:provider) { create :provider, username: 'ROB R' }
        let(:escaped_username) { URI.encode_www_form_component(provider.username).gsub('+', '%20') }

        it 'encodes with a %20 in place of a space' do
          expect(URI).to receive(:parse).at_least(:once).with(/#{escaped_username}/).and_call_original
          subject
        end
      end

      context 'on failure' do
        before do
          allow(Net::HTTP).to receive(:get_response).and_return(OpenStruct.new)
        end

        it 'raises error' do
          expect { subject }.to raise_error(described_class::ApiError)
        end
      end
    end
  end
end
