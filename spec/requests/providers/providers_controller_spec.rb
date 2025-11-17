require "rails_helper"
require Rails.root.join("spec/services/pda/provider_details_request_stubs")

RSpec.describe Providers::ProvidersController do
  let(:provider) { create(:provider) }

  before do
    stub_provider_user_for(provider.silas_id)

    login_as provider
  end

  context "when on any host environment" do
    before { get providers_provider_path }

    it "renders" do
      expect(response).to have_http_status(:ok)
    end

    it "displays the header" do
      expect(page).to have_css("h1", text: "Your profile")
    end

    it "displays provider data" do
      expect(page)
        .to have_content(provider.name)
        .and have_content(provider.email)
        .and have_content(provider.selected_office.code)
    end
  end

  context "when on test environment" do
    before do
      allow(HostEnv).to receive(:environment).and_return(:test)
      get providers_provider_path
    end

    it "does not display ccms_contact_id and username attributes" do
      expect(page).to have_no_content("CCMS")
    end
  end

  context "when on production environment" do
    before do
      allow(HostEnv).to receive(:environment).and_return(:production)
      get providers_provider_path
    end

    it "does not display ccms_contact_id and username attributes" do
      expect(page).to have_no_content("CCMS")
    end
  end

  context "when on development environment" do
    before do
      allow(HostEnv).to receive(:environment).and_return(:development)
      get providers_provider_path
    end

    it "displays ccms_contact_id and username attributes" do
      expect(page)
        .to have_content("CCMS Username")
        .and have_content("CCMS Contact ID")
    end
  end

  context "when on staging environment" do
    before do
      allow(HostEnv).to receive(:environment).and_return(:staging)
      get providers_provider_path
    end

    it "displays ccms_contact_id and username attributes" do
      expect(page)
        .to have_content("CCMS Username")
        .and have_content("CCMS Contact ID")
    end
  end

  context "when on UAT environment" do
    before do
      allow(HostEnv).to receive(:environment).and_return(:uat)
      get providers_provider_path
    end

    it "displays ccms_contact_id and username attributes" do
      expect(page)
        .to have_content("CCMS Username")
        .and have_content("CCMS Contact ID")
    end
  end

  context "when on development environment BUT user not found" do
    before do
      stub_provider_user_failure_for(provider.silas_id, status: 404)
      allow(HostEnv).to receive(:environment).and_return(:development)
      get providers_provider_path
    end

    it "displays ccms_contact_id and username attributes as \"Not found\"" do
      expect(page)
        .to have_content("CCMS UsernameNot found")
        .and have_content("CCMS Contact IDNot found")
    end
  end
end
