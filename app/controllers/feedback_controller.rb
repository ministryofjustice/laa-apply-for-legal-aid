class FeedbackController < ApplicationController
  before_action :update_return_path

  def new
    @journey = source
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new(feedback_params)
    # must use bang version `deliver_later!` or failures won't be retried by sidekiq
    if @feedback.save
      FeedbackMailer.notify(@feedback).deliver_later!
      render :show
    else
      render :new
    end
  end

  def show
    @feedback = Feedback.find(params[:id])
  end

  private

  def feedback_params
    params.require(:feedback).permit(
      :done_all_needed, :satisfaction, :difficulty, :improvement_suggestion
    ).merge(browser_meta_data)
  end

  def browser_meta_data
    { source: source,
      os: browser.platform.name,
      browser: browser.name,
      browser_version: browser.full_version }
  end

  def back_path
    session.fetch(:feedback_return_path, :back)
  end

  def success_message
    provider_signed_in? ? {} : I18n.t('feedback.new.signed_out')
  end

  def back_button
    provider_signed_in? ? {} : :none
  end

  helper_method :back_path, :back_button, :success_message

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
end
