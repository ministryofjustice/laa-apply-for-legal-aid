class CreateResultsPanelDecisions < ActiveRecord::Migration[6.1]
  def change
    create_table :results_panel_decisions, id: :uuid do |t|
      t.string :cfe_result, null: false
      t.boolean :disregards, default: false
      t.boolean :restrictions, default: false
      t.boolean :extra_employment_information, default: false
      t.string :decision, null: false

      t.timestamps
    end
  end
end
