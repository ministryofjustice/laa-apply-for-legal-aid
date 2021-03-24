require 'rails_helper'

RSpec.describe Admin::SettingsController, type: :request do
  let(:admin_user) { create :admin_user }

  before do
    Setting.delete_all
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
          allow_welsh_translation: 'true',
          allow_multiple_proceedings: 'true',
          override_dwp_results: 'true'
        }
      }
    end
    let(:setting) { Setting.setting }

    subject { patch admin_settings_path, params: params }

    after do
      Setting.delete_all
    end

    it 'change settings values' do
      subject
      expect(setting.mock_true_layer_data?).to eq(true)
      expect(setting.allow_welsh_translation?).to eq(true)
      expect(setting.allow_multiple_proceedings?).to eq(true)
      expect(setting.override_dwp_results?).to eq(true)
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
