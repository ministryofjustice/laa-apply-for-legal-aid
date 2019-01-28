class FeedbackMailer < GovukNotifyRails::Mailer
  TARGET_EMAIL = 'apply-for-legal-aid@digital.justice.gov.uk'.freeze

  def notify(feedback)
    set_template_conf
    set_personalisation(
      created_at: feedback.created_at.to_s(:rfc822),
      user_data: [
        feedback.os,
        "#{feedback.browser} #{feedback.browser_version}",
        feedback.source
      ].join(' - '),
      done_all_needed: feedback.done_all_needed.to_s,
      satisfaction: feedback.satisfaction,
      improvement_suggestion: feedback.improvement_suggestion
    )
    mail to: TARGET_EMAIL
  end

  protected

  def set_template_conf
    template_id = template_ids.fetch(:feedback_notification)
    set_template(template_id)
  end

  def template_ids
    @template_ids ||= Rails.configuration.govuk_notify_templates
  end
end
