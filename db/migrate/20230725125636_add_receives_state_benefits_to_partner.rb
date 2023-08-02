class AddReceivesStateBenefitsToPartner < ActiveRecord::Migration[7.0]
  def change
    add_column :partners, :receives_state_benefits, :boolean
  end
end
