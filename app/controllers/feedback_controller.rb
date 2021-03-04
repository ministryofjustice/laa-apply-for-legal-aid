class FeedbackController < ApplicationController
  before_action :update_return_path, :update_locale

  def new
    @journey = source
    @feedback = Feedback.new
    @signed_out = session.delete('signed_out')
  end

  def create
    initialize_feedback
    @display_close_tab_msg = params['signed_out'].present?

    if @feedback.save
      ScheduledMailing.send_now!(mailer_klass: FeedbackMailer,
                                 mailer_method: :notify,
                                 legal_aid_application_id: application_id,
                                 addressee: Rails.configuration.x.support_email_address,
                                 arguments: [@feedback.id, application_id])
      render :show
    else
      render :new
    end
  end

  def show
    @feedback = Feedback.find(params[:id])
  end

  private

  def initialize_feedback
    @feedback = Feedback.new(feedback_params)
    @feedback.originating_page = originating_page
    @feedback.email = provider_email
  end

  def provider_email
    # citizen side won't have access to current_provider but can get provider_email via current_application_id
    provider&.email || current_provider&.email
  end

  def provider
    LegalAidApplication.find_by(id: application_id)&.provider
  end

  def application_id
    return session['current_application_id'] if source == :citizen

    application_id_from_page_history || nil
  end

  def application_id_from_page_history
    page_history_service = PageHistoryService.new(page_history_id: session[:page_history_id])
    page_history = JSON.parse(page_history_service.read)
    previous_page = page_history[-2]

    previous_page&.split('/')&.each_with_index do |section, i|
      return previous_page.split('/')[i + 1] if ['applications'].include?(section)
    end
  end

  def originating_page
    params['signed_out'].present? ? destroy_provider_session_path : URI(session['feedback_return_path']).path.split('/').last
  end

  def feedback_params
    params.require(:feedback).permit(
      :done_all_needed, :satisfaction, :difficulty, :improvement_suggestion
    ).merge(browser_meta_data)
  end

  def browser_meta_data
    { source: user,
      os: browser.platform.name,
      browser: browser.name,
      browser_version: browser.full_version }
  end

  def user
    case source
    when :citizen
      'Applicant'
    when :provider
      'Provider'
    else
      'Unknown'
    end
  end

  def back_path
    session.fetch(:feedback_return_path, :back)
  end

  def success_message
    return {} if citizen_journey?

    provider_signed_in? ? {} : I18n.t('feedback.new.signed_out')
  end

  def citizen_journey?
    citizen_path_regex.match? session[:feedback_return_path]
  end

  def back_button
    provider_signed_in? ? {} : :none
  end

  helper_method :back_path, :back_button, :success_message

  def update_return_path
    return if request.referer&.include?('/feedback/')

    session[:feedback_return_path] = request.referer
  end

  def source
    path = session[:feedback_return_path]
    return :provider if %r{/providers/}.match?(path)
    return :citizen if %r{/citizens/}.match?(path)

    :unknown
  end

  def citizen_path_regex
    @citizen_path_regex ||= Regexp.new(/\/citizens\//)
  end
end
