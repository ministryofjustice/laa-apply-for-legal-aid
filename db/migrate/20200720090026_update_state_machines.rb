class UpdateStateMachines < ActiveRecord::Migration[6.0]
  def up
    LegalAidApplication.all.each do |application|
      type = application.passported? ? 'PassportedStateMachine' : 'NonPassportedStateMachine'
      application.create_state_machine!(type: type, aasm_state: application.read_attribute(:state))
    rescue StandardError
      message = "Cannot create a #{type} state machine for application: #{application.id} with an aasm_state of `#{application.read_attribute(:state)}`"
      raise message
    end

    remove_column :legal_aid_applications, :state, :string
  end

  def down
    add_column :legal_aid_applications, :state, :string

    LegalAidApplication.all.each do |application|
      application.state = application.state_machine_proxy.aasm_state
      application.state_machine_proxy.destroy!
      application.save!
    end
  end
end
