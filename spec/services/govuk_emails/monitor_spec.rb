require 'rails_helper'

RSpec.describe GovukEmails::Monitor do
  let(:scheduled_mailing) { create :scheduled_mailing, :processing }
  let(:response) { double GovukEmails::Email, status: status }

  before { allow(GovukEmails::Email).to receive(:new).with(scheduled_mailing.govuk_message_id).and_return(response) }

  describe '.call' do
    subject { described_class.call(scheduled_mailing.id) }

    context 'non-failure response' do
      let(:status) { 'delivered' }

      it 'updates the scheduled_mailing record' do
        subject
        expect(scheduled_mailing.reload.status).to eq 'delivered'
      end
    end

    context 'failure response' do
      let(:status) { ScheduledMailing::FAILURE_STATUSES.sample }
      let(:addressee) { scheduled_mailing.addressee }
      let(:id) { scheduled_mailing.id }
      let(:raven_message) { "Unable to deliver mail to #{addressee} - ScheduledMailing record #{id}" }

      it 'updates the scheduled_mailing record' do
        subject
        expect(scheduled_mailing.reload.status).to eq status
      end

      context 'on production host' do
        before { allow(HostEnv).to receive(:production?).and_return(true) }

        it 'captures raven message' do
          expect(Sentry).to receive(:capture_message).with(raven_message)
          subject
        end

        it 'schedules an undeliverable alert email' do
          expect { subject }.to change { ScheduledMailing.count }.by(1)
          undeliverable_mail = ScheduledMailing.order(:created_at).last

          expect(undeliverable_mail.legal_aid_application_id).to eq scheduled_mailing.legal_aid_application_id
          expect(undeliverable_mail.mailer_klass).to eq 'UndeliverableEmailAlertMailer'
          expect(undeliverable_mail.mailer_method).to eq 'notify_apply_team'
          expect(undeliverable_mail.arguments).to eq [scheduled_mailing.id]
          expect(undeliverable_mail.scheduled_at).to have_been_in_the_past
          expect(undeliverable_mail.addressee).to eq Rails.configuration.x.support_email_address
        end
      end

      context 'not on production host' do
        before { allow(HostEnv).to receive(:production?).and_return(false) }

        it 'does not captures raven message' do
          expect(Sentry).not_to receive(:capture_message)
          subject
        end

        it 'does not schedules an undeliverable alert email' do
          expect { subject }.not_to change { ScheduledMailing.count }
        end
      end
    end
  end
end
