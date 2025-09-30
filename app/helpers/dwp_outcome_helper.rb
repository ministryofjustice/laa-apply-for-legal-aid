module DWPOutcomeHelper
  def reset_confirm_dwp_status!(legal_aid_application)
    legal_aid_application.update!(dwp_result_confirmed: nil)
    legal_aid_application.save!
  end

  def checking_dwp_status!(legal_aid_application)
    legal_aid_application.update!(dwp_result_confirmed: false)
    legal_aid_application.save!
  end

  def confirm_dwp_status_correct!(legal_aid_application)
    legal_aid_application.update!(dwp_result_confirmed: true)
    legal_aid_application.save!
  end
end
