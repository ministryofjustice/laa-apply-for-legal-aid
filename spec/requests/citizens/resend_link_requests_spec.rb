require 'rails_helper'

RSpec.describe Citizens::ResendLinkRequestsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:secure_data_id) { legal_aid_application.generate_secure_id }

  describe 'GET /citizens/resend_link/:id' do
    subject { get citizens_resend_link_request_path(secure_data_id) }

    it 'renders page' do
      subject
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /citizens/resend_link/:id' do
    subject { patch citizens_resend_link_request_path(secure_data_id) }

    it 'renders page' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'schedules an email without an application id' do
      allow_any_instance_of(described_class).to receive(:secure_id).and_return(secure_data_id)
      expect { subject }.to change { ScheduledMailing.count }.by(1)
      rec = ScheduledMailing.first

      expect(rec.mailer_klass).to eq 'ResendLinkRequestMailer'
      expect(rec.mailer_method).to eq 'notify'
      expect(rec.legal_aid_application_id).to eq legal_aid_application.id
      expect(rec.addressee).to eq legal_aid_application.applicant.email_address
      expect(rec.arguments).to eq mailer_args
      expect(rec.scheduled_at).to have_been_in_the_past
    end

    def mailer_args
      [
        legal_aid_application.application_ref,
        legal_aid_application.applicant.email_address,
        citizens_legal_aid_application_url(secure_data_id),
        legal_aid_application.applicant.full_name
      ]
    end
  end
end
