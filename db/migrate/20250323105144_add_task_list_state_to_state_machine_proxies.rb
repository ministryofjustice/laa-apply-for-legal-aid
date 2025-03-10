class AddTaskListStateToStateMachineProxies < ActiveRecord::Migration[8.0]
  def change
    add_column :state_machine_proxies, :aasm_task_list_state, :string
  end
end
