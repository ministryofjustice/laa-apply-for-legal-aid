class CreateDWPOverrides < ActiveRecord::Migration[6.1]
  def change
    create_table :dwp_overrides, id: :uuid do |t|
      t.belongs_to :legal_aid_application, foreign_key: true, null: false, type: :uuid
      t.text :passporting_benefit
      t.boolean :evidence_available

      t.timestamps
    end
  end
end
