require 'rails_helper'

RSpec.describe Admin::SubmittedApplicationsReportsController, type: :request do
  let(:count) { 3 }
  let!(:legal_aid_applications) { create_list :legal_aid_application, count, :with_applicant, :with_ccms_submission, :submitted_to_ccms }
  let!(:unsubmitted_application) { create :legal_aid_application, :with_applicant }
  let(:admin_user) { create :admin_user }
  let(:params) { {} }

  before do
    sign_in admin_user
  end

  describe 'GET /admin/submitted_applications_report' do
    subject { get admin_submitted_applications_report_path(params) }

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'displays title' do
      subject
      expect(response.body).to include(I18n.t('admin.submitted_applications_reports.show.heading_1'))
    end

    it 'displays applications submitted to ccms' do
      subject
      legal_aid_applications.each do |application|
        expect(response.body).to include(application.application_ref)
      end
    end

    it 'does not display unsubmitted applications' do
      subject
      expect(response.body).not_to include(unsubmitted_application.application_ref)
    end

    context 'with pagination' do
      it 'shows current total information' do
        subject
        expect(response.body).to include('Showing 3 of 3')
      end

      it 'does not show navigation links' do
        subject
        expect(parsed_response_body.css('.pagination-container nav')).to be_empty
      end

      context 'and more applications than page size' do
        let(:params) { { page_size: 3 } }
        let(:count) { 5 }

        it 'show page information' do
          subject
          expect(response.body).to include('Showing 1 - 3 of 5 results')
        end

        it 'shows pagination' do
          subject
          expect(parsed_response_body.css('.pagination-container nav').text).to match(/Previous\s+1\s+2\s+Next/)
        end
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
