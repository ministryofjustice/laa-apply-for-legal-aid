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

    it 'sends an email' do
      mailer = double(deliver_later!: true)
      expect(ResendLinkRequestMailer).to receive(:notify).and_return(mailer)
      subject
    end
  end
end
