class AddSilasIdToProvider < ActiveRecord::Migration[8.0]
  def change
    add_column :providers, :silas_id, :string
  end
end
