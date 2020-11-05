require 'rails_helper'

RSpec.describe Admin::ReportsController, type: :request do
  let(:admin_user) { create :admin_user }
  before { sign_in admin_user }

  describe 'GET index' do
    subject { get admin_reports_path }

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'displays report name' do
      subject
      expect(response.body).to include('Download CSV of all submitted applications')
    end

    it 'has a link to the download csv path' do
      subject
      expect(response.body).to include(admin_reports_submitted_csv_path(format: :csv))
    end
  end

  describe 'GET download_submitted' do
    subject { get admin_reports_submitted_csv_path(format: :csv) }

    it 'calls the report generator' do
      expect(Reports::MIS::ApplicationDetailsReport).to receive(:new).and_call_original
      expect_any_instance_of(Reports::MIS::ApplicationDetailsReport).to receive(:run).and_call_original
      subject
    end

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'sends the data' do
      subject
      expect(response.body).to match(/^Firm name,User name,Office ID,Apply reference number,/)
    end
  end

  describe 'GET download_non_passported' do
    subject { get admin_reports_non_passported_csv_path(format: :csv) }

    it 'calls the report generator' do
      expect(Reports::MIS::NonPassportedApplicationsReport).to receive(:new).and_call_original
      expect_any_instance_of(Reports::MIS::NonPassportedApplicationsReport).to receive(:run).and_call_original
      subject
    end

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'sends the data' do
      subject
      expect(response.body).to match(/^application_ref,state,ccms_reason,username,provider_email,created_at/)
    end
  end
end
