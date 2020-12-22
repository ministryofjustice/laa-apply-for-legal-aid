class CreatePolicyDisregardsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :policy_disregards, id: :uuid do |t|
      t.boolean :england_infected_blood_support
      t.boolean :vaccine_damage_payments
      t.boolean :variant_creutzfeldt_jakob_disease
      t.boolean :criminal_injuries_compensation_scheme
      t.boolean :national_emergencies_trust
      t.boolean :we_love_manchester_emergency_fund
      t.boolean :london_emergencies_trust
      t.boolean 'none_selected'
      t.timestamps
      t.references :legal_aid_application, foreign_key: true, type: :uuid
    end
  end
end
