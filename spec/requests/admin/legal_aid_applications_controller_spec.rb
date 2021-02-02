require 'rails_helper'

RSpec.describe Admin::LegalAidApplicationsController, type: :request do
  let(:count) { 3 }
  let!(:legal_aid_applications) { create_list :legal_aid_application, count, :with_applicant, :with_non_passported_state_machine, :with_ccms_submission }
  let(:admin_user) { create :admin_user }
  let(:params) { {} }

  before { sign_in admin_user }

  describe 'GET /admin/legal_aid_applications' do
    subject { get admin_legal_aid_applications_path(params) }

    context 'not from a whitelisted IP address' do
      it 'redirects to error page' do
        # stub the response to request.env['HTTP_X_REAL_IP']
        Rails.application.env_config['HTTP_X_REAL_IP'] = '55.6.7.8'
        subject
        expect(response).to redirect_to(error_path(:access_denied))
        Rails.application.env_config['HTTP_X_REAL_IP'] = nil
      end
    end

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'displays applications' do
      subject
      legal_aid_applications.each do |application|
        expect(response.body).to include(application.application_ref)
      end
    end

    it 'has a link to settings' do
      subject
      expect(response.body).to include(admin_settings_path)
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

  describe 'POST /admin/search' do
    subject { post admin_application_search_path(params) }
    let(:params) { nil }
    before { subject }

    context 'when the params are empty' do
      it { expect(response.body).to include('Please enter a search criteria') }
    end

    context 'when the params match an application' do
      let(:params) { { search: legal_aid_applications.first.id } }

      it 'shows the matching application' do
        expect(response.body).to include(legal_aid_applications.first.application_ref)
        expect(response.body).to include('Showing 1 of 1 result')
      end
    end
  end

  describe 'POST /admin/legal_aid_applications/create_test_applications' do
    subject { post create_test_applications_admin_legal_aid_applications_path }
    let(:count) { 1 }

    it 'creates test legal_aid_applications' do
      number_new = TestApplicationCreationService::APPLICATION_TEST_TRAITS.size + TestApplicationCreationService::NON_PASSPORTED_TEST_TRAITS.size
      expect { subject }.to change { LegalAidApplication.count }.by(number_new)
    end

    it 'redirects back to admin root' do
      subject
      expect(response).to redirect_to(admin_root_path)
    end
  end

  describe 'DELETE /admin/legal_aid_applications/destroy_all' do
    subject { delete destroy_all_admin_legal_aid_applications_path }
    let(:scheduled_mail) { create :scheduled_mailing, :due }
    let(:scheduled_mail2) { create :scheduled_mailing, :due }

    context 'when enabled' do
      before do
        allow(Rails.configuration.x.admin_portal).to receive(:allow_reset).and_return(true)
      end

      it 'deletes the legal_aid_applications' do
        expect { subject }.to change { LegalAidApplication.count }.by(-count)
      end

      it 'deletes the applicants too' do
        expect { subject }.to change { Applicant.count }.by(-count)
      end

      it 'deletes the outstanding scheduled mail' do
        scheduled_mail
        scheduled_mail2
        expect { subject }.to change { ScheduledMailing.count }.by(-2)
      end

      it 'redirects back to admin root' do
        subject
        expect(response).to redirect_to(admin_root_path)
      end

      context 'when not authenticated' do
        before { sign_out admin_user }

        it 'redirects to log in' do
          subject
          expect(response).to redirect_to(new_admin_user_session_path)
        end
      end

      context 'with a lot of associations' do
        let!(:another) { create :legal_aid_application, :with_everything }

        it 'gets deleted too' do
          expect { subject }.to change { LegalAidApplication.count }.to(0)
        end
      end
    end

    context 'when disabled' do
      before do
        allow(Rails.configuration.x.admin_portal).to receive(:allow_reset).and_return(false)
      end
      it 'raises an error' do
        expect { subject }.to raise_error('Legal Aid Application Destroy All action disabled')
      end
    end
  end

  describe 'DELETE /admin/legal_aid_applications/:legal_aid_application_id/destroy' do
    let(:application) { legal_aid_applications.first }
    subject { delete admin_legal_aid_application_path(application) }

    context 'when enabled' do
      before do
        allow(Rails.configuration.x.admin_portal).to receive(:allow_reset).and_return(true)
      end

      it 'deletes the legal_aid_application' do
        expect { subject }.to change { LegalAidApplication.count }.by(-1)
        expect(LegalAidApplication.all).not_to include(application)
      end

      it 'deletes the applicant too' do
        expect { subject }.to change { Applicant.count }.by(-1)
      end

      it 'redirects back to admin root' do
        subject
        expect(response).to redirect_to(admin_root_path)
      end

      context 'when not authenticated' do
        before { sign_out admin_user }

        it 'redirects to log in' do
          subject
          expect(response).to redirect_to(new_admin_user_session_path)
        end
      end

      context 'with a lot of associations' do
        let!(:application) { create :legal_aid_application, :at_assessment_submitted }

        it 'gets deleted too' do
          expect { subject }.to change { LegalAidApplication.count }.by(-1)
        end
      end

      context 'application has no applicant' do
        let!(:application) { create :legal_aid_application }

        it 'gets deleted too' do
          expect { subject }.to change { LegalAidApplication.count }.by(-1)
          expect { subject }.not_to change { Applicant.count }
        end
      end
    end

    context 'when disabled' do
      before do
        allow(Rails.configuration.x.admin_portal).to receive(:allow_reset).and_return(false)
      end
      it 'raises an error' do
        expect { subject }.to raise_error('Legal Aid Application Destroy action disabled')
      end
    end
  end
end
