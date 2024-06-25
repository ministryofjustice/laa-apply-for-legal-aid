class AddSCATypeToProceedings < ActiveRecord::Migration[7.1]
  def change
    add_column :proceedings, :sca_type, :string
  end
end
