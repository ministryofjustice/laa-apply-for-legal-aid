require 'rails_helper'

RSpec.describe 'Providers::BaseController' do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:provider) { create(:provider) }
  subject { get providers_legal_aid_application_proceedings_types_path(legal_aid_application) }

  context '#provider_not_authorized' do
    before do
      login_as provider
      subject
    end

    it 'returns http forbidden' do
      expect(response).to have_http_status(:forbidden)
    end
  end
end
