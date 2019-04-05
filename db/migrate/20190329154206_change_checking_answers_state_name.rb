class ChangeCheckingAnswersStateName < ActiveRecord::Migration[5.2]
  def up
    LegalAidApplication.where(state: :checking_answers).update_all(state: :checking_client_details_answers)
    LegalAidApplication.where(state: :answers_checked).update_all(state: :client_details_answers_checked)
  end

  def down
    LegalAidApplication.where(state: :checking_client_details_answers).update_all(state: :checking_answers)
    LegalAidApplication.where(state: :client_details_answers_checked).update_all(state: :answers_checked)
  end
end
