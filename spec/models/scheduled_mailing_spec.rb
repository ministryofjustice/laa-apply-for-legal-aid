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
    let(:now) { Time.now }

    it 'delivers the mail' do
      expect(SubmitApplicationReminderMailer)
        .to receive(:notify_provider)
        .with(scheduled_mail.legal_aid_application_id, 'Bob Marley', 'bob@wailing.jm')
        .and_return(mail_message)
      expect(mail_message).to receive(:deliver_later!)
      scheduled_mail.deliver!
    end

    it 'marks the record as sent' do
      scheduled_mail.deliver!
      expect(scheduled_mail.reload.sent_at.to_s).to eq now.to_s
    end
  end

  describe '#cancel!' do
    let(:scheduled_mail) { create :scheduled_mailing }
    let(:now) { Time.now }

    it 'updates the record as cancelled' do
      Timecop.freeze(now) do
        scheduled_mail.cancel!
        expect(scheduled_mail.reload.cancelled_at.to_s).to eq now.to_s
      end
    end
  end
end
