class AddExtraFieldsToProceedings < ActiveRecord::Migration[6.1]
  def change
    add_column :proceedings, :matter_type, :string
    add_column :proceedings, :category_of_law, :string
    add_column :proceedings, :category_law_code, :string
  end
end
