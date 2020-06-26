class UpdateStates < ActiveRecord::Migration[6.0]
  STATE_CHANGES = {
    initiated: {
      new_state: :entering_applicant_details,
      conditions: nil
    },
    checking_client_details_answers: {
      new_state: :checking_applicant_details,
      conditions: nil
    },
    client_details_answers_checked: {
      new_state: :applicant_details_checked,
      conditions: %|provider_step = 'check_benefits'|
    },
    client_details_answers_checked: {
      new_state: :provider_entering_means,
      conditions: %|provider_step != 'check_benefits'|
    }
  }


  STATE_CHANGES = {
    initiated: :entering_applicant_details,
    checking_client_details_answers: :checking_applicant_details
    # client_details_answers_checked: :applicant_details_checked
  }.freeze

  def up
    STATE_CHANGES.each do |old_state_name, new_state_name|
      sql = "UPDATE legal_aid_applications SET state = '#{new_state_name}' WHERE state = '#{old_state_name}'"
      puts sql
      execute sql
    end

    sql = "UPDATE legal_aid_applications SET state = 'applicant_details_checked' WHERE state = 'client_details_answers_checked' AND provider_step = 'check_provider_answers'"
    sql =
  end

  def down
    STATE_CHANGES.each do |old_state_name, new_state_name|
      sql = "UPDATE legal_aid_applications SET state = '#{old_state_name}' WHERE state = '#{new_state_name}'"
      puts sql
      execute sql
    end
  end
end
