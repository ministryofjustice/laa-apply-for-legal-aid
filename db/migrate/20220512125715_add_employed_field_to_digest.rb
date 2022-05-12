class AddEmployedFieldToDigest < ActiveRecord::Migration[6.1]
  def change
    change_table :application_digests do |t|
      t.boolean :employed, null: false, default: false
      t.boolean :hmrc_data_used, null: false, default: false
      t.boolean :referred_to_caseworker, null: false, default: false
    end
  end
end
