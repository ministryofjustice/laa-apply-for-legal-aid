class CreateStateMachineProxies < ActiveRecord::Migration[6.0]
  def change
    create_table :state_machine_proxies, id: :uuid do |t|
      t.uuid :legal_aid_application_id
      t.string :type
      t.string :aasm_state
      t.timestamps
    end
  end
end
