require 'rails_helper'

module HMRC
  RSpec.describe OAuth do
    subject(:base) { described_class.new }
    before { stub_request(:post, url).to_return({ body: response1 }, { body: response2 }) }
    let(:url) { 'https://test-api.service.hmrc.gov.uk/oauth/token' }
    let(:response1) { build(:hmrc_oauth_response).to_json }
    let(:response2) { build(:hmrc_oauth_response).to_json }

    describe '#call' do
      subject(:call) { base.call }

      it { is_expected.to be_a Faraday::Connection }
    end

    describe '#bearer_token' do
      subject(:get_bearer_token) { base.bearer_token }

      before { get_bearer_token }
      it 'calls the api' do
        expect(a_request(:post, url)).to have_been_made.times(1)
      end

      context 'when passed a reset indicator'
      subject(:reset_bearer_token) { base.bearer_token(force_reset: true) }

      before { base.bearer_token }

      it { expect { reset_bearer_token }.to change { base.bearer_token } }
    end
  end
end
