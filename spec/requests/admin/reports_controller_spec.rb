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

  describe "GET user feedback" do
    subject(:get_request) { get admin_user_feedbacks_csv_path(format: :csv) }

    before { create(:feedback, :from_provider, improvement_suggestion: "My suggested improvement") }

    it "renders successfully" do
      get_request
      expect(response).to have_http_status(:ok)
    end

    it "sends the data" do
      get_request
      expect(response.body).to match(/^date,time,source,satisfaction,difficulty,improvement_suggestion/)
      expect(response.body).to match(/My suggested improvement/)
    end
  end

  describe "GET application digest" do
    subject(:get_request) { get admin_application_digest_csv_path(format: :csv) }

    before do
      create(
        :application_digest,
        firm_name: "An Awesome Firm",
        provider_username: "Joe Bloggs",
      )
    end

    it "renders successfully" do
      get_request
      expect(response).to have_http_status(:ok)
    end

    it "sends the data" do
      get_request
      expect(response.body)
        .to include(*%w[legal_aid_application_id firm_name provider_username date_started date_submitted days_to_submission use_ccms matter_types proceedings passported df_used earliest_df_date df_reported_date working_days_to_report_df working_days_to_submit_df employed hmrc_data_used referred_to_caseworker true_layer_path bank_statements_path true_layer_data has_partner contrary_interest partner_dwp_challenge applicant_age non_means_tested family_linked family_linked_lead_or_associated number_of_family_linked_applications legal_linked legal_linked_lead_or_associated number_of_legal_linked_applications no_fixed_address biological_parent parental_responsibility_agreement parental_responsibility_court_order child_subject parental_responsibility_evidence autogranted ecct_routed An Awesome Firm Joe Bloggs])
    end
  end
end
