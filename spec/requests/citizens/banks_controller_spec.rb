require "rails_helper"

RSpec.describe Citizens::BanksController do
  let(:application) { create(:application, :with_applicant, :with_non_passported_state_machine, :applicant_entering_means) }
  let!(:banks) { create(:true_layer_bank).banks }
  let(:enable_mock) { false }

  before do
    sign_in_citizen_for_application(application)
    allow(Rails.configuration.x.true_layer).to receive(:enable_mock).and_return(enable_mock)
  end

  describe "GET citizens/banks" do
    before { get citizens_banks_path }

    it "shows the banks" do
      banks.each do |bank|
        expect(response.body).to include(bank[:display_name])
        expect(response.body).to include(bank[:provider_id])
        expect(response.body).to include(bank[:logo_url])
      end
    end

    it "does not show the mock bank" do
      expect(response.body).not_to include("mock")
    end

    context "when enable_mock is set to true" do
      let(:enable_mock) { true }

      it "shows the mock bank" do
        expect(response.body).to include("mock")
      end
    end
  end

  describe "POST citizens/banks" do
    let(:provider_id) { Faker::Bank.name }

    before { post citizens_banks_path, params: { provider_id: } }

    it "redirects to the next page" do
      expect(response).to have_http_status(:redirect)
    end

    it "sets provider_id in the session" do
      expect(session[:provider_id]).to eq(provider_id)
    end

    it "sets the default locale in the session" do
      expect(session[:locale]).to eq(:en)
    end

    context "with Welsh locale" do
      before { post citizens_banks_path, params: { provider_id: } }

      around do |example|
        I18n.with_locale(:cy) { example.run }
      end

      it "sets locale in the session" do
        expect(session[:locale]).to eq(:cy)
      end
    end

    context "with no bank selected" do
      let(:provider_id) { nil }

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "shows an error" do
        expect(response.body).to include(I18n.t("citizens.banks.create.error"))
      end
    end
  end
end
