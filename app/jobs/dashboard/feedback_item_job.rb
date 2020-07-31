module Dashboard
  class FeedbackItemJob < ActiveJob::Base
    def perform(feedback)
      Dashboard::SingleObject::Feedback.new(feedback).run
    end
  end
end
