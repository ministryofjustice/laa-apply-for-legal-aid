require 'rails_helper'

RSpec.describe ScheduledMailing do
  describe '.due_now' do
    before do
      create_list :scheduled_mailing, 2
      create_list :scheduled_mailing, 2, :sent
      create :scheduled_mailing, :cancelled
    end

    context 'only mails that are due in the past and sent and due in the future and unsent' do
      it 'returns and empty array' do
        expect(ScheduledMailing.due_now).to be_empty
      end
    end

    context 'mails that are unsent and in the past' do
      before { create_list :scheduled_mailing, 3, :due }
      it 'returns a collection of three records' do
        expect(ScheduledMailing.due_now.size).to eq 3
      end
    end
  end

  describe '#deliver!' do
    let(:scheduled_mail) { create :scheduled_mailing, :due }
    let(:mail_message) { double 'mail message' }
    let(:now) { Time.zone.now }

    context 'scheduled_mails are checked for eligibility prior to sending' do
      let(:scheduled_mail) { create :scheduled_mailing, :provider_financial_reminder, legal_aid_application: legal_aid_application }
      context 'the mail is eligible to be sent' do
        let(:legal_aid_application) { create :legal_aid_application, :at_client_completed_means }

        it 'delivers the mail' do
          Timecop.freeze(now) do
            expect(SubmitProviderFinancialReminderMailer)
              .to receive(:notify_provider)
              .with(scheduled_mail.legal_aid_application_id, 'Bob Marley', 'bob@wailing.jm')
              .and_return(mail_message)
            expect(mail_message).to receive(:deliver_now)
            scheduled_mail.deliver!
            expect(scheduled_mail.reload.sent_at.to_s).to eq now.to_s
          end
        end
      end

      context 'the mail is not eligible to be sent' do
        let(:legal_aid_application) { create :legal_aid_application, :at_client_completed_means }

        it 'does not deliver the mail' do
          expect_any_instance_of(SubmitProviderFinancialReminderMailer).not_to receive(:notify_provider)
          scheduled_mail.deliver!
          expect(scheduled_mail.reload.sent_at).to be_nil
        end
      end
    end
  end

  context 'when it tries to send mail with no attached application' do
    let(:application) { create :legal_aid_application }
    let!(:scheduled_mail) { create :scheduled_mailing, :invalid, legal_aid_application: application }

    it 'captures error' do
      expect(Raven).to receive(:capture_exception).with(message_contains("Couldn't find LegalAidApplication with 'id"))
      scheduled_mail.deliver!
    end

    it 'returns false' do
      expect(scheduled_mail.deliver!).to eq false
    end
  end

  describe '#cancel!' do
    let(:scheduled_mail) { create :scheduled_mailing }
    let(:now) { Time.zone.now }

    it 'updates the record as cancelled' do
      Timecop.freeze(now) do
        scheduled_mail.cancel!
        expect(scheduled_mail.reload.cancelled_at.to_s).to eq now.to_s
      end
    end
  end
end
