require "rails_helper"

RSpec.describe FeedbackMailer do
  describe "notify" do
    let(:feedback) { create(:feedback) }
    let(:application) { create(:application) }
    let(:application_id) { application.id }
    let(:mail) { described_class.notify(feedback.id, application_id) }

    it "sends to correct address" do
      expect(mail.to).to eq([Rails.configuration.x.support_email_address])
    end

    it "is a govuk_notify delivery" do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    context "with personalisation" do
      describe "application_status" do
        context "with pre_dwp_check" do
          before { allow(application).to receive(:pre_dwp_check?).and_return(true) }

          it "has a status of pre dwp check" do
            expect(mail.govuk_notify_personalisation[:application_status]).to eq "pre-dwp-check"
          end
        end

        context "when application state is not a pre_dwp_check state" do
          let(:application) { create(:application, :assessment_submitted) }

          it "does not have a status of pre dwp check" do
            expect(mail.govuk_notify_personalisation[:application_status]).not_to eq "pre-dwp-check"
          end
        end

        context "when passported" do
          let(:application) { create(:application, :with_passported_state_machine, :provider_entering_merits) }

          it "has a status of passported" do
            expect(mail.govuk_notify_personalisation[:application_status]).to eq "passported"
          end
        end

        context "when non-passported" do
          let(:application) { create(:application, :with_non_passported_state_machine, :checking_non_passported_means) }

          it "has a status of non-passported" do
            expect(mail.govuk_notify_personalisation[:application_status]).to eq "non-passported"
          end
        end

        context "when no legal_aid_application is present" do
          let(:application_id) { nil }

          it "has an empty status" do
            expect(mail.govuk_notify_personalisation[:application_status]).to eq ""
          end
        end
      end
    end
  end
end
