class FeedbackMailer < BaseApplyMailer
  self.delivery_job = GovukNotifyMailerJob

  require_relative 'concerns/notify_template_methods'
  include NotifyTemplateMethods

  def notify(feedback, to = support_email_address)
    template_name :feedback_notification

    set_personalisation(
      created_at: feedback.created_at&.to_time&.to_s(:rfc822),
      user_data: [
        feedback.os,
        "#{feedback.browser} #{feedback.browser_version}",
        feedback.source
      ].join(' - '),
      done_all_needed: yes_or_no(feedback),
      satisfaction: safe_nil(feedback.satisfaction),
      difficulty: safe_nil(feedback.difficulty),
      improvement_suggestion: safe_nil(feedback.improvement_suggestion),
      originating_page: safe_nil(feedback.originating_page),
      provider_email: safe_nil(feedback.email)
    )
    mail to: to
  end

  private

  def yes_or_no(feedback)
    feedback['done_all_needed'] == true ? 'Yes' : 'No'
  end
end
