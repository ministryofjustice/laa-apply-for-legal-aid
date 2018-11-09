class AddTrueLayerTokenToApplicants < ActiveRecord::Migration[5.2]
  def change
    add_column :applicants, :true_layer_token, :text
    add_column :applicants, :true_layer_token_expires_at, :datetime
  end
end
