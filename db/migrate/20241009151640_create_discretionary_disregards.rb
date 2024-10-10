class CreateDiscretionaryDisregards < ActiveRecord::Migration[7.2]
  def change
    create_table :discretionary_disregards, id: :uuid do |t|
      t.boolean :backdated_benefits
      t.boolean :compensation_for_personal_harm
      t.boolean :criminal_injuries_compensation
      t.boolean :grenfell_tower_fire_victims
      t.boolean :london_emergencies_trust
      t.boolean :national_emergencies_trust
      t.boolean :loss_or_harm_relating_to_this_application
      t.boolean :victims_of_overseas_terrorism_compensation
      t.boolean :we_love_manchester_emergency_fund
      t.boolean "none_selected"
      t.timestamps
      t.references :legal_aid_application, foreign_key: true, type: :uuid
    end
  end
end
