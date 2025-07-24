module DWPOutcomeHelper
  def reset_confirm_dwp_status!(legal_aid_application)
    legal_aid_application.update!(confirm_dwp_result: nil)
    legal_aid_application.save!
  end

  def confirm_dwp_status_correct!(legal_aid_application)
    legal_aid_application.update!(confirm_dwp_result: "dwp_correct")
    legal_aid_application.save!
  end
end
