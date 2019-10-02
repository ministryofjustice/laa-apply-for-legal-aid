require 'rails_helper'

RSpec.describe GovukEmails::Email do
  let(:message_id) { 'ad9559be-f32d-4674-91dd-87c50d4a16b2' }

  subject { described_class.new(message_id) }

  context "status is 'delivered'", vcr: { cassette_name: 'govuk_email_delivered' } do
    it { is_expected.to be_delivered }
    it { is_expected.not_to be_should_resend }
    it { is_expected.not_to be_permanently_failed }
  end

  context 'status is not delivered' do
    let(:govuk_client) { double(Notifications::Client) }
    before do
      allow(govuk_client).to receive(:get_notification).with(message_id).and_return(OpenStruct.new(status: status))
      allow(Notifications::Client).to receive(:new).with(Rails.configuration.x.govuk_notify_api_key).and_return(govuk_client)
    end

    context "status is a permanent failure'" do
      let(:status) { described_class::PERMANENTLY_FAILED_STATUS }

      it { is_expected.not_to be_delivered }
      it { is_expected.not_to be_should_resend }
      it { is_expected.to be_permanently_failed }
    end

    context 'status is temporary or technical failure' do
      let(:status) { described_class::RESENDABLE_STATUS.sample }

      it { is_expected.not_to be_delivered }
      it { is_expected.to be_should_resend }
      it { is_expected.not_to be_permanently_failed }
    end

    context 'status is something else' do
      let(:status) { Faker::Lorem.word }

      it { is_expected.not_to be_delivered }
      it { is_expected.not_to be_should_resend }
      it { is_expected.not_to be_permanently_failed }
    end
  end
end
