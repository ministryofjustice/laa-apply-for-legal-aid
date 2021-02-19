class CitizenConfirmationMailer < BaseApplyMailer
  # Require relative statement required as concern not found when loaded from sidekiq on retry
  require_relative 'concerns/notify_template_methods'
  include NotifyTemplateMethods

  def citizen_complete_email(app_id, email, client_name)
    template_name :citizen_completed_application
    set_personalisation(
      client_name: client_name,
      ref_number: app_id
    )
    mail(to: email)
  end
end
