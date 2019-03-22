class AddTrueLayerSecureDataIdToApplicants < ActiveRecord::Migration[5.2]
  def change
    add_column :applicants, :true_layer_secure_data_id, :string
  end
end
