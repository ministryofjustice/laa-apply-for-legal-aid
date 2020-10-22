class FeedbackMailer < BaseApplyMailer
  self.delivery_job = GovukNotifyMailerJob

  require_relative 'concerns/notify_template_methods'
  include NotifyTemplateMethods

  def notify(feedback, legal_aid_application_id, to = support_email_address)
    template_name :feedback_notification
    legal_aid_application(legal_aid_application_id)
    personalise feedback
    mail to: to
  end

  private

  def personalise(feedback) # rubocop:disable Metrics/AbcSize
    set_personalisation(
      created_at: feedback.created_at&.to_time.to_s(:rfc822),
      user_data: user_data(feedback),
      user_type: feedback.source,
      done_all_needed: yes_or_no(feedback),
      satisfaction: safe_nil(feedback.satisfaction),
      difficulty: safe_nil(feedback.difficulty),
      improvement_suggestion: safe_nil(feedback.improvement_suggestion),
      originating_page: safe_nil(feedback.originating_page),
      provider_email: provider_email_phrase(feedback),
      application_reference: @legal_aid_application&.application_ref || '',
      application_status: application_status || ''
    )
  end

  def application_status
    return 'pre-dwp-check' if @legal_aid_application&.pre_dwp_check?

    @legal_aid_application&.passported? ? 'passported' : 'non-passported'
  end

  def legal_aid_application(legal_aid_application_id)
    @legal_aid_application ||= LegalAidApplication.find_by_id(legal_aid_application_id)
  end

  def user_data(feedback)
    "#{feedback.os} :: #{feedback.browser} #{feedback.browser_version} :: #{feedback.source}"
  end

  def yes_or_no(feedback)
    feedback['done_all_needed'] == true ? 'Yes' : 'No'
  end

  def provider_email_phrase(feedback)
    return '' if feedback.email.nil?

    "from #{feedback.email}"
  end
end
