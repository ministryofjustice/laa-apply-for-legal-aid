class AddVersionTypeToCFEResults < ActiveRecord::Migration[5.2]
  def change
    add_column :cfe_results, :type, :string, default: 'CFE::V1::Result'
  end
end
