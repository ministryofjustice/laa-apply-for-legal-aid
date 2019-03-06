require 'rails_helper'

RSpec.describe Admin::LegalAidApplicationsController, type: :request do
  let(:count) { 3 }
  let!(:legal_aid_applications) { create_list :legal_aid_application, count, :with_applicant }
  let(:admin_user) { create :admin_user }

  before { sign_in admin_user }

  describe 'GET /admin/legal_aid_applications' do
    subject { get admin_legal_aid_applications_path }

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

    context 'when not authenticated' do
      before { sign_out admin_user }

      it 'redirects to log in' do
        subject
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end

  describe 'DELETE /admin/legal_aid_applications/destroy_all' do
    subject { delete destroy_all_admin_legal_aid_applications_path }

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
    subject { delete admin_legal_aid_application_destroy_path(application) }

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
        let!(:application) { create :legal_aid_application, :with_everything }

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
