class CreateSavingAmounts < ActiveRecord::Migration[5.2]
  def change
    create_table :savings_amounts, id: :uuid do |t|
      t.belongs_to :legal_aid_application, foreign_key: true, null: false, type: :uuid
      t.decimal :isa
      t.decimal :cash
      t.decimal :other_person_account
      t.decimal :national_savings
      t.decimal :plc_shares
      t.decimal :peps_unit_trusts_capital_bonds_gov_stocks
      t.decimal :life_assurance_endowment_policy

      t.timestamps
    end
  end
end
