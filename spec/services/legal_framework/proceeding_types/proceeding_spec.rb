require 'rails_helper'

RSpec.describe LegalFramework::ProceedingTypes::Proceeding, :vcr do
  subject(:proceeding) { described_class }
  let(:ccms_code) { 'DA004' }
  let(:uri) { "#{Rails.configuration.x.legal_framework_api_host}/proceeding_types/#{ccms_code}" }
  describe '.call' do
    subject(:call) { proceeding.call(ccms_code) }
    before { call }

    it 'makes one external call' do
      expect(a_request(:get, uri)).to have_been_made.times(1)
    end

    it 'returns a success status' do
      expect(call.success).to eq true
    end

    it 'returns details of the correct proceeding' do
      expect(call.ccms_code).to eq ccms_code
    end
  end
end
