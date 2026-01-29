class FeedbackController < ApplicationController
  before_action :update_return_path, :update_locale

  def new
    @journey = source
    @feedback = Feedback.new
    @signed_out = session.delete("signed_out")
    @submission_feedback = submission_feedback?
    if submission_feedback?
      application = LegalAidApplication.find_by(application_ref: params[:application_ref])
      @application_id = application.id
    end
    render :new
  end
  alias_method :submission, :new

  def create
    initialize_feedback

    if @feedback.save
      redirect_to feedback_thanks_path
    else
      render :new
    end
  end

  def thanks; end

private

  def initialize_feedback
    @feedback = Feedback.new(feedback_params)
    @feedback.originating_page = originating_page
    @feedback.email = provider_email
    @feedback.legal_aid_application_id = application_id
  end

  def provider_email
    # citizen side won't have access to current_provider but can get provider_email via current_application_id
    provider&.email || current_provider&.email
  end

  def provider
    LegalAidApplication.find_by(id: application_id)&.provider
  end

  def application_id
    return session["current_application_id"] if source == :citizen
    return params[:application_id] if submission_feedback?

    application_id_from_page_history || nil
  end

  def application_id_from_page_history
    page_history_service = PageHistoryService.new(page_history_id: session[:page_history_id])
    page_history = JSON.parse(page_history_service.read)
    previous_page = page_history[-2]

    previous_page&.split("/")&.each_with_index do |section, i|
      return previous_page.split("/")[i + 1] if %w[applications].include?(section)
    end
  end

  def originating_page
    return "submission_feedback" if submission_feedback?

    params["signed_out"].present? ? destroy_provider_session_path : originating_last_path
  end

  def originating_last_path
    return unless session["feedback_return_path"]

    URI(session["feedback_return_path"]).path.split("/").last
  end

  def feedback_params
    params.expect(
      feedback: %i[done_all_needed
                   done_all_needed_reason
                   satisfaction
                   satisfaction_reason
                   difficulty
                   difficulty_reason
                   time_taken_satisfaction
                   time_taken_satisfaction_reason
                   improvement_suggestion
                   contact_name
                   contact_email],
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
      "Applicant"
    when :provider
      "Provider"
    else
      "Unknown"
    end
  end

  def back_path
    session.fetch(:feedback_return_path, :back)
  end

  def back_button
    provider_signed_in? ? {} : :none
  end

  helper_method :back_path, :back_button

  def update_return_path
    return if request.referer&.match?(/\/feedback[?\/]/)

    session[:feedback_return_path] = request.referer
  end

  def source
    path = session[:feedback_return_path].to_s
    return :provider if path.include?("/providers/")
    return :citizen if path.include?("/citizens/")

    :unknown
  end

  def submission_feedback?
    params[:action] == "submission" || params[:submission_feedback] == "true"
  end
end
