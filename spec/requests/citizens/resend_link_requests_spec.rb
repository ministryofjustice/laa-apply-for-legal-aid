require 'rails_helper'
require 'sidekiq/testing'

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

    context 'sending the email', :vcr do
      before do
        ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.clear
        allow_any_instance_of(Notifications::Client).to receive(:get_notification).and_return(OpenStruct.new(status: 'delivered'))
        allow_any_instance_of(DashboardEventHandler).to receive(:call).and_return(double(DashboardEventHandler))
      end

      it 'sends an email with the right parameters' do
        expect_any_instance_of(ResendLinkRequestMailer)
          .to receive(:set_personalisation)
          .with(hash_including(application_ref: legal_aid_application.application_ref))
          .and_call_original
        subject
        ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.drain
      end
    end
  end
end
