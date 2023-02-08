class AddEncryptedTrueLayerTokenToApplicants < ActiveRecord::Migration[7.0]
  def change
    add_column :applicants, :encrypted_true_layer_token, :jsonb, null: true
  end
end
