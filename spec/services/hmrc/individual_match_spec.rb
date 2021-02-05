require 'rails_helper'

module HMRC
  RSpec.describe IndividualMatch do
    subject(:individual_match) { described_class.new(applicant) }

    before do
      stub_request(:post, oauth_url).to_return(body: build(:hmrc_oauth_response).to_json)
      # stub_request(:post, api_url).with(body: request).to_return(body: response)
      stub_request(:post, api_url).to_return(body: response)
    end
    let(:oauth_url) { 'https://test-api.service.hmrc.gov.uk/oauth/token' }
    let(:api_url) { 'https://test-api.service.hmrc.gov.uk/individuals/matching' }

    let(:request) { { firstName: 'Amanda', lastName: 'Joseph', nino: 'NA000799C', dateOfBirth: '1960-01-15' } }

    let(:response) do
      {
        _links: {
          individual: {
            href: '/individuals/matching/57072660-1df9-4aeb-b4ea-cd2d7f96e430',
            name: 'GET',
            title: 'Get a matched individual’s information'
          },
          self: {
            href: '/individuals/matching/'
          }
        }
      }.to_json
    end

    let(:applicant) { create(:applicant, first_name: 'Amanda', last_name: 'Joseph', national_insurance_number: 'NA000799C', date_of_birth: '1960-01-15') }

    describe '#call' do
      subject(:call) { individual_match.call }
      before { subject }
      it 'calls the hmrc api' do
        expect(a_request(:post, api_url)).to have_been_made.times(1)
      end
    end
  end
end
