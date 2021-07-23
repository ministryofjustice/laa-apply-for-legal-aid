class EnableCCMSSubmission
  def self.call
    Rails.configuration.x.ccms_soa.submit_applications_to_ccms && Setting.enable_ccms_submission?
  end
end
