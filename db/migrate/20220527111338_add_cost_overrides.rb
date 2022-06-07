class AddCostOverrides < ActiveRecord::Migration[6.1]
  def change
    change_table :legal_aid_applications, bulk: true do |t|
      t.boolean :substantive_cost_override, null: true
      t.numeric :substantive_cost_requested, null: true
      t.string :substantive_cost_reasons, null: true
    end
  end
end
