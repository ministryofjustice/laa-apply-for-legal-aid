class FeedbackController < ApplicationController
  def new
    feedback
  end

  def create
    if feedback.update(feedback_params)
      redirect_to feedback
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
      :done_all_needed, :satisfaction, :improvment_suggestion
    )
  end

  def feedback
    @feedback ||= Feedback.new
  end
end
