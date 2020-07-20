class UpdateStateMachines < ActiveRecord::Migration[6.0]
  def up
    LegalAidApplication.all.each do |application|
      application.create_state_machine!(type: 'PassportedStateMachine', aasm_state: application.read_attribute(:state))
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
