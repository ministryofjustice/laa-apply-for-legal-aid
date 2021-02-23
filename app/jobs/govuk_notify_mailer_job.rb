class GovukNotifyMailerJob < ActionMailer::MailDeliveryJob
  self.log_arguments = false

  def perform(mailer, mail_method, delivery_method, args:)
    email_args, govuk_message_id = extract_govuk_message_id(args)
    GovukEmails::EmailMonitor.call(
      mailer: mailer,
      mail_method: mail_method,
      delivery_method: delivery_method,
      email_args: email_args,
      govuk_message_id: govuk_message_id
    )
  end

  def extract_govuk_message_id(args)
    govuk_message_id = nil
    email_args = args

    last_arg = args.last
    if last_arg.is_a?(Hash) && last_arg.key?('govuk_message_id')
      govuk_message_id = last_arg['govuk_message_id']
      email_args = args[0...-1]
    end

    [email_args, govuk_message_id]
  end
end
