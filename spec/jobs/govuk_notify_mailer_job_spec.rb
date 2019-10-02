require 'rails_helper'

RSpec.describe GovukNotifyMailerJob, type: :job do
  let(:mailer) { Faker::Lorem.sentence }
  let(:mail_method) { Faker::Lorem.sentence }
  let(:delivery_method) { Faker::Lorem.sentence }
  let(:email_args) { ['foobar', { 'foo' => 'bar' }] }

  subject { GovukNotifyMailerJob.new.perform(mailer, mail_method, delivery_method, *email_args) }

  describe '#perform' do
    it 'calls GovukEmails::EmailMonitor' do
      expect(GovukEmails::EmailMonitor).to receive(:call).with(
        mailer: mailer,
        mail_method: mail_method,
        delivery_method: delivery_method,
        email_args: email_args,
        govuk_message_id: nil
      )
      subject
    end

    context 'govuk_message_id is present in the params' do
      let(:govuk_message_id) { SecureRandom.uuid }
      let(:email_args) { ['foobar', { 'foo' => 'bar' }, { 'govuk_message_id' => govuk_message_id }] }

      it 'calls GovukEmails::EmailMonitor with govuk_message_id' do
        expect(GovukEmails::EmailMonitor).to receive(:call).with(
          mailer: mailer,
          mail_method: mail_method,
          delivery_method: delivery_method,
          email_args: email_args[0...-1],
          govuk_message_id: govuk_message_id
        )
        subject
      end
    end
  end
end
