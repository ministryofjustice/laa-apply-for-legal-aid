class AddSilasUuidToProvider < ActiveRecord::Migration[8.0]
  def change
    add_column :providers, :silas_uuid, :string
  end
end
