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
end
