class CreateTrueLayerBanks < ActiveRecord::Migration[5.2]
  def change
    create_table :true_layer_banks, id: :uuid do |t|
      t.text :banks

      t.timestamps
    end
  end
end
