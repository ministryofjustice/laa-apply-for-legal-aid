class FeedbackController < ApplicationController
  before_action :print_session, :update_return_path

  def new
    @journey = source
    @feedback = Feedback.new
    @signed_out_provider_id = session.delete('signed_out_provider_id')
  end

  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.originating_page = originating_page
    @feedback.email = provider_email

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
  
  def print_session
    puts ">>>>>>>>>>>> SESSION #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
    puts session.to_h.inspect
  end

  def provider_email
    if params[:signed_out_provider_id].present?
      signed_out_provider_email
    else
      signed_in_provider_email
    end
  end

  def signed_out_provider_email
    provider_id = params[:signed_out_provider_id]
    Provider.find(provider_id).email
  end

  def signed_in_provider_email
    provider_struct = session['warden.user.provider.key']
    return nil unless provider_struct

    provider_id = provider_struct.first&.first
    return nil unless provider_id

    Provider.find(provider_id).email
  end

  def originating_page
    params[:signed_out_provider_id].present? ? destroy_provider_session_path : session['feedback_return_path']
  end

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
    puts ">>>>>>>>>>>> updating return path #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
    puts request.referrer
    return if request.referer&.include?(feedback_index_path)

    session[:feedback_return_path] = request.referer
  end

  def source
    path = session[:feedback_return_path]
    return :provider if %r{/providers/}.match?(path)
    return :citizen if %r{/citizens/}.match?(path)

    :unknown
  end
end
