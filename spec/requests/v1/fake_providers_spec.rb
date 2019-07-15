require 'rails_helper'

RSpec.describe V1::FakeProvidersController, type: :request do
  describe 'GET /v1/fake_providers/:username' do
    let(:username) { Faker::Internet.username }
    let(:contact_name) { username.snakecase.titlecase }

    subject { get v1_fake_provider_path(username) }

    before { subject }

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'returns the expected data structure' do
      expect(json['contactName']).to eq(contact_name)
      expected_keys = %w[providerOffices contactId contactName]
      expect(json.keys).to match_array(expected_keys)

      expected_office_keys = %w[providerfirmId officeId officeName smsVendorNum smsVendorSite]
      expect(json['providerOffices'][0].keys).to match_array(expected_office_keys)
    end

    it 'returns the same providerfirmId for each office' do
      expect(json['providerOffices'].pluck('providerfirmId').uniq.count).to eq(1)
    end
  end
end
