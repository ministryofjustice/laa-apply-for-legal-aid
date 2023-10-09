class TestMailJob
  include Sidekiq::Worker
  sidekiq_options queue: :default

  CLIENT_CONFIRMATION_EMAIL = "3b18efe5-7d09-4042-927c-7d1ae03fdd7e".freeze

  def perform(email, name)
    client = Notifications::Client.new(Rails.configuration.x.govuk_notify_api_key)

    client.send_email(
      email_address: email,
      template_id: CLIENT_CONFIRMATION_EMAIL,
      personalisation: {
        client_name: name,
        ref_number: "testing-whatever",
      },
    )
  end
end
