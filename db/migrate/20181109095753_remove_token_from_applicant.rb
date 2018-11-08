class RemoveTokenFromApplicant < ActiveRecord::Migration[5.2]
  def change
    remove_column :applicants, :true_layer_token, :text
    remove_column :applicants, :true_layer_token_expires_at, :datetime
  end
end
