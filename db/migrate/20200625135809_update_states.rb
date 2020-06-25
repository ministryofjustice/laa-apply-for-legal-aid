class UpdateStates < ActiveRecord::Migration[6.0]
  STATE_CHANGES = {
    initiated: :entering_applicant_details,
    checking_client_details_answers: :checking_applicant_details,
    client_details_answers_checked: :applicant_details_checked
  }.freeze

  def up
    STATE_CHANGES.each do |old_state_name, new_state_name|
      sql = "UPDATE legal_aid_applications SET state = '#{new_state_name}' WHERE state = '#{old_state_name}'"
      puts sql
      execute sql
    end
  end

  def down
    STATE_CHANGES.each do |old_state_name, new_state_name|
      sql = "UPDATE legal_aid_applications SET state = '#{old_state_name}' WHERE state = '#{new_state_name}'"
      puts sql
      execute sql
    end
  end
end
