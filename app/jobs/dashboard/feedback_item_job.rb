module Dashboard
  class FeedbackItemJob < ActiveJob::Base
    include SuspendableJob

    def perform(feedback)
      return if job_suspended?

      Dashboard::SingleObject::Feedback.new(feedback).run
    end
  end
end
