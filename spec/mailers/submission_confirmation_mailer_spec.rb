require 'rails_helper'

RSpec.describe SubmissionConfirmationMailer, type: :mailer do
  describe '.notify' do
    let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
    let(:provider) { legal_aid_application.provider }
    let(:applicant) { legal_aid_application.applicant }
    let(:feedback_url) { 'www.example.com/feedback/new' }
    let(:mail) { described_class.notify(legal_aid_application.id, feedback_url) }

    it 'sends to correct address' do
      expect(mail.to).to eq([provider.email])
    end

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the correct template' do
      template = Rails.configuration.govuk_notify_templates.key(mail.govuk_notify_template)
      expect(template).to eq(:submission_confirmation)
    end

    it 'has the right personalisation' do
      expect(mail.govuk_notify_personalisation).to eq(
        provider_name: provider.name,
        client_name: applicant.full_name,
        ref_number: legal_aid_application.application_ref,
        feedback_url: feedback_url
      )
    end
  end
end
