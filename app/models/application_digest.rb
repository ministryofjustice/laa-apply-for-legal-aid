class ApplicationDigest < ApplicationRecord

  def as_json(options = nil)
    {
      applicationId: id,
      providerName: name,
      dateStarted: date_started,
      dateSubmitted: date_submitted,
      daysToSubmission: days_to_submission
    }
  end
end
