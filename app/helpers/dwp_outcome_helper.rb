module DWPOutcomeHelper
  def reset_confirm_dwp_status!(application)
    application.dwp_override&.destroy!
    dwp_result_confirmation!(application, nil)
  end

  def checking_dwp_status!(application)
    dwp_result_confirmation!(application, false)
  end

  def confirm_dwp_status_correct!(application)
    dwp_result_confirmation!(application, true)
  end

private

  def dwp_result_confirmation!(application, val)
    application.update!(dwp_result_confirmed: val)
  end
end
