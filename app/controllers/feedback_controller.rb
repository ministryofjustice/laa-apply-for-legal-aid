class FeedbackController < ApplicationController
  before_action :update_return_path

  def new
    feedback
  end

  def create
    if feedback_params.values.any?(&:present?)
      feedback.update(feedback_params)
      redirect_to feedback
    else
      feedback
      render :new
    end
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
    @feedback ||= Feedback.new
  end

  def back_path
    session.fetch(:feedback_return_path, :back)
  end
  helper_method :back_path

  def update_return_path
    return if request.referer&.include?(feedback_index_path)

    session[:feedback_return_path] = request.referer
  end
end
