module DWPOutcomeHelper
  def reset_confirm_dwp_status!
    legal_aid_application.update!(confirm_dwp_result: nil)
    legal_aid_application.save!
  end

  def update_confirm_dwp_status(new_status)
    legal_aid_application.update!(confirm_dwp_result: new_status)
    legal_aid_application.save!
  end
end
