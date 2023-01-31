class AddBankingPathsToApplicationDigest < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      change_table :application_digests, bulk: true do |t|
        t.boolean :true_layer_path, null: true
        t.boolean :bank_statements_path, null: true
        t.boolean :true_layer_data, null: true
      end
    end
  end
end
