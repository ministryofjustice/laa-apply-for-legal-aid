require 'rails_helper'

RSpec.describe GovukEmails::EmailMonitor do
  include ActiveJob::TestHelper

  let(:arg_govuk_message_id) { SecureRandom.uuid }
  let(:status_govuk_message_id) { arg_govuk_message_id }
  let(:mailer) { 'FeedbackMailer' }
  let(:mail_method) { 'notify' }
  let(:delivery_method) { 'deliver_now!' }
  let(:feedback_email_params) { create :feedback }
  let(:to) { 'julien.sansot@digital.justice.gov.uk' }
  let(:email_args) { [feedback_email_params, to] }
  let(:message_status) { 'sending' }
  let!(:stub_send_email) do
    stub_request(:post, 'https://api.notifications.service.gov.uk/v2/notifications/email')
      .to_return(status: 200, body: { id: status_govuk_message_id }.to_json)
  end
  let!(:stub_email_status) do
    stub_request(:get, "https://api.notifications.service.gov.uk/v2/notifications/#{status_govuk_message_id}")
      .to_return(status: 200, body: { status: message_status }.to_json)
  end
  let(:params) do
    {
      mailer: mailer,
      mail_method: mail_method,
      delivery_method: delivery_method,
      email_args: email_args,
      govuk_message_id: arg_govuk_message_id
    }
  end
  let(:email_monitor) { described_class.new(**params) }

  subject { email_monitor.call }

  describe '#call' do
    context 'email has not been sent yet' do
      let(:message_status) { 'sending' }
      let(:arg_govuk_message_id) { nil }
      let(:status_govuk_message_id) { SecureRandom.uuid }

      it 'sends the email' do
        subject
        expect(stub_send_email).to have_been_requested
      end

      it 'keeps monitoring the email' do
        expect(email_monitor).to receive(:trigger_job).with(status_govuk_message_id)
        subject
      end

      it 'does not send a new email' do
        expect(email_monitor).not_to receive(:trigger_job).with(nil)
        subject
      end

      it 'does not check its status now' do
        subject
        expect(stub_email_status).not_to have_been_requested
      end
    end

    context 'email has already been sent at least once' do
      context 'email has been delivered' do
        let(:message_status) { GovukEmails::Email::DELIVERED_STATUS }

        it 'does not send the email' do
          subject
          expect(stub_send_email).not_to have_been_requested
        end

        it 'does not capture an exception' do
          expect(Raven).not_to receive(:capture_exception).with(message_contains(error_message))
          subject
        end

        it 'does not re-trigger the job for monitoring or sending a new email' do
          expect(email_monitor).not_to receive(:trigger_job)
          subject
        end
      end

      context 'email is still pending' do
        let(:message_status) { 'pending' }

        it 'does not send the email' do
          subject
          expect(stub_send_email).not_to have_been_requested
        end

        it 'does not capture an exception' do
          expect(Raven).not_to receive(:capture_exception).with(message_contains(error_message))
          subject
        end

        it 'keeps monitoring the email' do
          expect(email_monitor).to receive(:trigger_job).with(arg_govuk_message_id)
          subject
        end

        it 'does not send a new email' do
          expect(email_monitor).not_to receive(:trigger_job).with(nil)
          subject
        end
      end

      context 'email permanently failed' do
        let(:message_status) { GovukEmails::Email::PERMANENTLY_FAILED_STATUS }

        it 'does not send the email' do
          subject
          expect(stub_send_email).not_to have_been_requested
        end

        it 'captures an exception' do
          expect(Raven).to receive(:capture_exception).with(message_contains(error_message))
          subject
        end

        it 'does not re-trigger the job for monitoring or sending a new email' do
          expect(email_monitor).not_to receive(:trigger_job)
          subject
        end
      end

      context 'email failed and can be resent' do
        let(:message_status) { GovukEmails::Email::RESENDABLE_STATUS.sample }

        it 'does not send the email' do
          subject
          expect(stub_send_email).not_to have_been_requested
        end

        it 'does not capture an exception' do
          expect(Raven).not_to receive(:capture_exception).with(message_contains(error_message))
          subject
        end

        it 'stops monitoring the email' do
          expect(email_monitor).not_to receive(:trigger_job).with(arg_govuk_message_id)
          subject
        end

        it 'sends a new email' do
          expect(email_monitor).to receive(:trigger_job).with(nil)
          subject
        end
      end
    end

    context "govuk_notify can't find email" do
      before do
        allow_any_instance_of(Notifications::Client)
          .to receive(:get_notification)
          .and_raise(Notifications::Client::NotFoundError, OpenStruct.new(code: 404, body: ''))
      end

      it 'raises and error' do
        expect { subject }.to raise_error(Notifications::Client::NotFoundError)
      end

      context 'email is to simulated test email address' do
        let(:to) { Rails.configuration.x.simulated_email_address }

        it 'does not raise and error' do
          expect { subject }.not_to raise_error
        end
      end
    end
  end

  describe '#trigger_job' do
    let(:message_id) { SecureRandom.uuid }
    let(:enqueued_job) { enqueued_jobs.find { |job| job[:job] == GovukNotifyMailerJob } }

    it 'triggers the job to be sent in 5 seconds' do
      email_monitor.trigger_job(message_id)
      expect(Time.zone.at(enqueued_job[:at])).to be_within(2.seconds).of(Time.current + described_class::JOBS_DELAY)
    end

    it 'passes the correct parameters' do
      email_monitor.trigger_job(message_id)
      expect(GovukNotifyMailerJob).to(
        have_been_enqueued.with(mailer, mail_method, delivery_method, args: [feedback_email_params, to, { 'govuk_message_id' => message_id }])
      )
    end

    context 'without message_id' do
      let(:message_id) { nil }

      it 'passes the correct parameters' do
        email_monitor.trigger_job(message_id)
        expect(GovukNotifyMailerJob).to(
          have_been_enqueued.with(mailer, mail_method, delivery_method, args: [feedback_email_params, to])
        )
      end
    end
  end

  def error_message
    [
      '*Email ERROR*',
      "*#{mailer}.#{mail_method}* could not be sent",
      "*GovUk email status:* #{message_status}",
      email_args.to_s
    ].join("\n")
  end
end
