class FeedbackController < ApplicationController
  before_action :update_return_path

  def new
    feedback
  end

  def create
    feedback.update!(feedback_params)
    # Must use bang version `deliver_later!` or failures won't be retried by sidekiq
    FeedbackMailer.notify(feedback).deliver_later! if feedback_submitted?

    redirect_to feedback
  end

  def show
    @feedback = Feedback.find(params[:id])
  end

  private

  def feedback_params
    params.require(:feedback).permit(
      :done_all_needed, :satisfaction, :improvement_suggestion
    )
  end

  def feedback
    @feedback ||= Feedback.new(
      source: source,
      os: browser.platform.name,
      browser: browser.name,
      browser_version: browser.full_version
    )
  end

  def back_path
    session.fetch(:feedback_return_path, :back)
  end
  helper_method :back_path

  def update_return_path
    return if request.referer&.include?(feedback_index_path)

    session[:feedback_return_path] = request.referer
  end

  def source
    path = session[:feedback_return_path]
    return :Provider if %r{/providers/}.match?(path)
    return :Citizen if %r{/citizens/}.match?(path)

    :Unknown
  end

  def feedback_submitted?
    feedback_params.values.any?(&:present?)
  end
end
