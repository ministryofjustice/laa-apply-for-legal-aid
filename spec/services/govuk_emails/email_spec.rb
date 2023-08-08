require "rails_helper"

StatusStruct = Struct.new(:status)

RSpec.describe GovukEmails::Email do
  subject { described_class.new(message_id) }

  let(:govuk_client) { double(Notifications::Client) }
  let(:message_id) { "ad9559be-f32d-4674-91dd-87c50d4a16b2" }

  before do
    allow(govuk_client).to receive(:get_notification).with(message_id).and_return(StatusStruct.new(status))
    allow(Notifications::Client).to receive(:new).with(Rails.configuration.x.govuk_notify_api_key).and_return(govuk_client)
  end

  context "when the status is 'delivered'", vcr: { cassette_name: "govuk_email_delivered" } do
    let(:status) { described_class::DELIVERED_STATUS }

    it { is_expected.to be_delivered }
    it { is_expected.not_to be_should_resend }
    it { is_expected.not_to be_permanently_failed }
  end

  context "when the status is not delivered" do
    context "and the status is a permanent failure'" do
      let(:status) { described_class::PERMANENTLY_FAILED_STATUS }

      it { is_expected.not_to be_delivered }
      it { is_expected.not_to be_should_resend }
      it { is_expected.to be_permanently_failed }
    end

    context "and the status is temporary or technical failure" do
      let(:status) { described_class::RESENDABLE_STATUS.sample }

      it { is_expected.not_to be_delivered }
      it { is_expected.to be_should_resend }
      it { is_expected.not_to be_permanently_failed }
    end

    context "and the status is something else" do
      let(:status) { Faker::Lorem.word }

      it { is_expected.not_to be_delivered }
      it { is_expected.not_to be_should_resend }
      it { is_expected.not_to be_permanently_failed }
    end
  end
end
