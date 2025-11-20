require "rails_helper"

RSpec.describe Admin::SettingsController do
  let(:admin_user) { create(:admin_user) }

  before do
    Setting.delete_all
    sign_in admin_user
  end

  describe "GET /admin/settings" do
    subject(:get_request) { get admin_settings_path }

    it "renders successfully" do
      get_request
      expect(response).to have_http_status(:ok)
    end

    it "displays title" do
      get_request
      expect(response.body).to include(I18n.t("admin.settings.show.heading_1"))
    end

    context "when not authenticated" do
      before { sign_out admin_user }

      it "redirects to log in" do
        get_request
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end

  describe "PATCH /admin/settings" do
    subject(:patch_request) { patch admin_settings_path, params: }

    let(:params) do
      {
        setting: {
          mock_true_layer_data: "true",
          allow_welsh_translation: "true",
          enable_ccms_submission: "true",
          collect_hmrc_data: "true",
          home_address: "true",
          collect_dwp_data: "true",
          enable_datastore_submission: "true",
        },
      }
    end
    let(:setting) { Setting.setting }

    after do
      Setting.delete_all
    end

    it "changes settings values" do
      patch_request
      expect(setting.mock_true_layer_data?).to be(true)
      expect(setting.allow_welsh_translation?).to be(true)
      expect(setting.collect_hmrc_data?).to be(true)
      expect(setting.collect_dwp_data?).to be(true)
      expect(setting.enable_datastore_submission?).to be(true)
    end

    it "creates settings if they do not exist" do
      expect { patch_request }.to change(Setting, :count).from(0).to(1)
    end

    it "redirects to the same page" do
      patch_request
      expect(response).to redirect_to(admin_settings_path)
    end

    context "when the enable_ccms_submission is changed" do
      before do
        allow(CCMS::RestartSubmissions).to receive(:new).and_return(ccms_restart_submissions)
        allow(ccms_restart_submissions).to receive(:call).and_return(true)
      end

      let(:ccms_restart_submissions) { instance_double(CCMS::RestartSubmissions) }

      context "when from false to true" do
        it "calls CCMS::RestartSubmissions" do
          expect(CCMS::RestartSubmissions).to receive(:call)
          patch_request
        end
      end

      context "when from true to false" do
        let(:params) do
          {
            setting: {
              mock_true_layer_data: "true",
              allow_welsh_translation: "true",
              enable_ccms_submission: "false",
            },
          }
        end

        it "does not send an active_support notification" do
          expect(CCMS::RestartSubmissions).not_to receive(:call)
          patch_request
        end
      end
    end

    context "when Setting already exist" do
      before { Setting.create! }

      it "does not add another Setting object" do
        expect(Setting.count).to eq(1)
      end
    end

    context "when no params were sent" do
      let(:params) do
        {
          setting: {
            mock_true_layer_data: nil,
          },
        }
      end

      it "renders show" do
        patch_request
        expect(response).to have_http_status(:ok)
      end
    end

    context "when not authenticated" do
      before { sign_out admin_user }

      it "redirects to log in" do
        patch_request
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end
end
