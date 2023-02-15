class RemoveTrueLayerSecureDataIdFromApplicants < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :applicants, :true_layer_secure_data_id, :string, null: true }
  end
end
