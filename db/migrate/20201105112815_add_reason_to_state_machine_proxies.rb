class AddReasonToStateMachineProxies < ActiveRecord::Migration[6.0]
  def up
    add_column :state_machine_proxies, :ccms_reason, :string
    execute "UPDATE state_machine_proxies SET ccms_reason = 'unknown' WHERE aasm_state = 'use_ccms'"
  end
end
