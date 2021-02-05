require 'rails_helper'

module HMRC
  RSpec.describe HelloWorld do
    subject(:hello_world) { described_class.new }
    before do
      stub_request(:post, oauth_url).to_return(body: build(:hmrc_oauth_response).to_json)
      stub_request(:get, api_url).to_return(body: { 'message' => 'Hello Application' }.to_json)
    end
    let(:oauth_url) { 'https://test-api.service.hmrc.gov.uk/oauth/token' }
    let(:api_url) { 'https://test-api.service.hmrc.gov.uk/hello/application' }

    describe '#call' do
      subject(:call) { hello_world.call }
      it 'calls the hmrc api' do
        expect(subject).to match({ 'message' => 'Hello Application' })
        expect(a_request(:post, oauth_url)).to have_been_made.times(1)
        expect(a_request(:get, api_url)).to have_been_made.times(1)
      end
    end
  end
end
