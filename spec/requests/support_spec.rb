require 'rails_helper'

RSpec.describe '/support', type: :request do
  subject { get '/support' }

  it 'redirects to log in' do
    subject
    expect(response).to redirect_to(new_admin_user_session_path)
  end

  context 'when authenticated' do
    let(:admin_user) { create :admin_user }
    before { sign_in admin_user }

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end
  end
end
