require 'rails_helper'

RSpec.describe FeedbackMailer, type: :mailer do
  describe 'notify' do
    let(:feedback) { create :feedback }
    let(:application) { create :application }
    let(:mail) { described_class.notify(feedback.id, application.id) }

    it 'sends to correct address' do
      expect(mail.to).to eq([Rails.configuration.x.support_email_address])
    end

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    context 'personalisation' do
      describe 'application_status' do
        context 'pre_dwp_check' do
          before { allow_any_instance_of(LegalAidApplication).to receive(:pre_dwp_check?).and_return(true) }
          it 'has a status of pre dwp check' do
            expect(mail.govuk_notify_personalisation[:application_status]).to eq 'pre-dwp-check'
          end
        end

        context 'when application state is not a pre_dwp_check state' do
          let(:application) { create :application, :assessment_submitted }

          it 'does not have a status of pre dwp check' do
            expect(mail.govuk_notify_personalisation[:application_status]).not_to eq 'pre-dwp-check'
          end
        end

        context 'passported' do
          before do
            allow_any_instance_of(LegalAidApplication).to receive(:pre_dwp_check?).and_return(false)
            allow_any_instance_of(LegalAidApplication).to receive(:passported?).and_return(true)
          end
          it 'has a status of passported' do
            expect(mail.govuk_notify_personalisation[:application_status]).to eq 'passported'
          end
        end
        context 'non-passported' do
          before do
            allow_any_instance_of(LegalAidApplication).to receive(:pre_dwp_check?).and_return(false)
            allow_any_instance_of(LegalAidApplication).to receive(:passported?).and_return(false)
          end
          it 'has a status of passported' do
            expect(mail.govuk_notify_personalisation[:application_status]).to eq 'non-passported'
          end
        end
      end
    end
  end
end
