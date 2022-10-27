require "rails_helper"

RSpec.describe Admin::ReportsController do
  let(:admin_user) { create(:admin_user) }

  before { sign_in admin_user }

  describe "GET index" do
    subject { get admin_reports_path }

    it "renders successfully" do
      subject
      expect(response).to have_http_status(:ok)
    end

    it "displays report name" do
      subject
      expect(response.body).to include("Application Details report")
    end

    it "has a link to the download csv path" do
      subject
      expect(response.body).to include(admin_application_details_csv_path(format: :csv))
    end
  end

  describe "GET application details" do
    subject { get admin_application_details_csv_path(format: :csv) }

    before do
      create(:admin_report, :with_reports_attached)
    end

    it "renders successfully" do
      subject
      expect(response).to have_http_status(:ok)
    end

    it "sends the data" do
      subject
      expect(response.body).to match(/^col1,col2,col3/)
    end
  end
end
