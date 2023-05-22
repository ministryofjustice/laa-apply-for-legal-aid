class AddReceivesStateBenefitsToApplicant < ActiveRecord::Migration[7.0]
  def change
    add_column :applicants, :receives_state_benefits, :boolean
  end
end
