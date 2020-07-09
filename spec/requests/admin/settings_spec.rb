require 'rails_helper'

RSpec.describe Admin::SettingsController, type: :request do
  let(:admin_user) { create :admin_user }
  let(:env_allow_non_passported_route) { true }

  before do
    allow(Rails.configuration.x).to receive(:allow_non_passported_route).and_return(env_allow_non_passported_route)
    sign_in admin_user
  end

  describe 'GET /admin/settings' do
    subject { get admin_settings_path }

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'displays title' do
      subject
      expect(response.body).to include(I18n.t('admin.settings.show.heading_1'))
    end

    it 'shows allow_non_passported_route setting' do
      subject
      expect(response.body).to include('allow_non_passported_route')
    end

    context 'when environment is not allowed to go through non-passported route' do
      let(:env_allow_non_passported_route) { false }

      it 'does not show allow_non_passported_route setting' do
        subject
        expect(response.body).not_to include('allow_non_passported_route')
      end
    end

    context 'when not authenticated' do
      before { sign_out admin_user }

      it 'redirects to log in' do
        subject
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end

  describe 'PATCH /admin/settings' do
    let(:params) do
      {
        setting: {
          mock_true_layer_data: 'true',
          allow_non_passported_route: 'false'
        }
      }
    end
    let(:setting) { Setting.setting }

    subject { patch admin_settings_path, params: params }

    it 'change settings values' do
      subject
      expect(Setting.mock_true_layer_data?).to eq(true)
      expect(Setting.allow_non_passported_route?).to eq(false)
    end

    it 'create settings if they do not exist' do
      expect { subject }.to change { Setting.count }.from(0).to(1)
    end

    it 'redirects to the same page' do
      subject
      expect(response).to redirect_to(admin_settings_path)
    end

    context 'Setting already exist' do
      before { Setting.create! }

      it 'does not add another Setting object' do
        expect { subject }.not_to change { Setting.count }
        expect(Setting.count).to eq(1)
      end
    end

    context 'no params where sent' do
      let(:params) do
        {
          setting: {
            mock_true_layer_data: nil
          }
        }
      end

      it 'renders show' do
        subject
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when not authenticated' do
      before { sign_out admin_user }

      it 'redirects to log in' do
        subject
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end
end
