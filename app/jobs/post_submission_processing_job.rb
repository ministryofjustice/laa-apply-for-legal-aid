class PostSubmissionProcessingJob < ApplicationJob
  queue_as :default

  def perform(legal_aid_application_id, feedback_url)
    SubmissionConfirmationMailer.notify(legal_aid_application_id, feedback_url).deliver_later!
    @legal_aid_application = LegalAidApplication.find(legal_aid_application_id)
    # No need to cancel reminder mailings anymore - they will see for themselves whether they are needed
    # and cancel themselves if not.
  end
end
