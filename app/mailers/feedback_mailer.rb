class FeedbackMailer < GovukNotifyRails::Mailer
  TARGET_EMAIL = 'apply-for-legal-aid@digital.justice.gov.uk'.freeze

  include NotifyTemplateMethods

  def notify(feedback)
    template_name :feedback_notification
    set_personalisation(
      created_at: feedback.created_at.to_s(:rfc822),
      user_data: [
        feedback.os,
        "#{feedback.browser} #{feedback.browser_version}",
        feedback.source
      ].join(' - '),
      done_all_needed: feedback.done_all_needed.to_s,
      satisfaction: (feedback.satisfaction || ''),
      improvement_suggestion: (feedback.improvement_suggestion || '')
    )
    mail to: TARGET_EMAIL
  end
end
