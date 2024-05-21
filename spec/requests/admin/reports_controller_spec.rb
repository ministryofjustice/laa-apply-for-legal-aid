require "rails_helper"

RSpec.describe Admin::ReportsController do
  let(:admin_user) { create(:admin_user) }

  before { sign_in admin_user }

  describe "GET index" do
    subject(:get_request) { get admin_reports_path }

    it "renders successfully" do
      get_request
      expect(response).to have_http_status(:ok)
    end

    it "displays report name" do
      get_request
      expect(response.body).to include("Application Details report")
    end

    it "has a link to the download csv path" do
      get_request
      expect(response.body).to include(admin_application_details_csv_path(format: :csv))
    end
  end

  describe "GET application details" do
    subject(:get_request) { get admin_application_details_csv_path(format: :csv) }

    before do
      create(:admin_report, :with_reports_attached)
    end

    it "renders successfully" do
      get_request
      expect(response).to have_http_status(:ok)
    end

    it "sends the data" do
      get_request
      expect(response.body).to match(/^col1,col2,col3/)
    end
  end

  describe "GET provider emails" do
    subject(:get_request) { get admin_provider_emails_csv_path(format: :csv) }

    before { create(:provider, email: "test1@example.com") }

    it "renders successfully" do
      get_request
      expect(response).to have_http_status(:ok)
    end

    it "sends the data" do
      get_request
      expect(response.body).to match(/^email,last_active/)
      expect(response.body).to match(/^test1@example.com/)
    end
  end
end
