require 'rails_helper'

RSpec.describe AddressLookupService do
  subject(:service) { described_class.new(postcode) }

  let(:query_params) do
    {
      key: ENV['ORDNANACE_SURVEY_API_KEY'],
      postcode: postcode,
      lr: 'EN'
    }
  end
  let(:api_request_uri) do
    uri = URI.parse(described_class::ORDNANCE_SURVEY_URL)
    uri.query = query_params.to_query
    uri
  end
  let(:postcode) { 'SW1H9AJ' }

  describe '#call' do
    context 'when the lookup is successful' do
      let(:stubbed_json_body) { file_fixture('address_lookups/success.json') }

      before do
        stub_request(:get, api_request_uri)
          .to_return(status: 200, body: stubbed_json_body)
      end

      context 'but the response does not contain any results' do
        let(:postcode) { 'W1A1AA' }
        let(:stubbed_json_body) { file_fixture('address_lookups/no_results.json') }

        it 'outcome is unsuccessful' do
          outcome = service.call
          expect(outcome).not_to be_success
          expect(outcome.errors).to eq(lookup: [:no_results])
          expect(outcome.result).to eq([])
        end
      end

      it 'returns a list of mapped addresses' do
        outcome = service.call
        expect(outcome).to be_success
        expect(outcome.errors).to be_empty
        expect(outcome.result).to all(be_an(Address))
      end
    end

    context 'when there is a problem connecting to the postcode API' do
      before do
        stub_request(:get, api_request_uri)
          .to_raise(Errno::ECONNREFUSED)
      end

      it 'outcome is unsuccessful' do
        outcome = service.call
        expect(outcome).not_to be_success
        expect(outcome.errors).to eq(lookup: [:service_unavailable])
        expect(outcome.result).to eq([])
      end
    end

    context 'when the lookup service is not successful' do
      let(:stubbed_body) do
        {
          error: {
            statuscode: 400,
            message: 'No postcode parameter provided.'
          }
        }
      end

      before do
        stub_request(:get, api_request_uri)
          .to_return(status: 400, body: stubbed_body.to_json)
      end

      it 'outcome is unsuccessful' do
        outcome = service.call
        expect(outcome).not_to be_success
        expect(outcome.errors).to eq(lookup: [:unsuccessful])
        expect(outcome.result).to eq([])
      end
    end
  end
end
