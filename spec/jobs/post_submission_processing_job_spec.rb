require 'rails_helper'

RSpec.describe PostSubmissionProcessingJob, type: :job do
  let(:application) { create :legal_aid_application }
  let(:feedback_url) { 'www.example.com/feedback/new' }
  subject { described_class.new.perform(application.id, feedback_url) }

  describe 'SubmissionConfirmationMailer' do
    it 'calls deliver on the mail item' do
      mail = double 'mail_object'
      expect(SubmissionConfirmationMailer).to receive(:notify).with(application.id, feedback_url).and_return(mail)
      expect(mail).to receive(:deliver_later!)
      subject
    end
  end

  describe 'Cancellation of Scheduled mailings' do
    let!(:mailing_one) { create :scheduled_mailing, legal_aid_application: application }
    let!(:mailing_two) { create :scheduled_mailing, legal_aid_application: application }
    let!(:mailing_three) { create :scheduled_mailing, legal_aid_application: application, mailer_klass: 'other_mailer_class' }

    it 'cancels submission reminder scheduled mailings' do
      subject
      expect(mailing_one.reload.cancelled_at).not_to be_nil
      expect(mailing_two.reload.cancelled_at).not_to be_nil
      expect(mailing_three.reload.cancelled_at).to be_nil
    end
  end
end
