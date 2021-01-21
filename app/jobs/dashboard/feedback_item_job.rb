module Dashboard
  class FeedbackItemJob < ApplicationJob
    include SuspendableJob

    def perform(feedback)
      return if job_suspended?

      Dashboard::SingleObject::Feedback.new(feedback).run
    end
  end
end
