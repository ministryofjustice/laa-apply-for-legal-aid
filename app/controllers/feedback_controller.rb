class FeedbackController < ApplicationController
  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new
    @feedback.errors.add(:improvment_suggestion, 'this is an error')
    render :new
  end
end
