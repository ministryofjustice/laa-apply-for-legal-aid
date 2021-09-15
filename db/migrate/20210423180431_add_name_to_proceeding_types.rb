class AddNameToProceedingTypes < ActiveRecord::Migration[6.1]
  def up
    add_column :proceeding_types, :name, :string
  end

  def down
    remove_column :proceeding_types, :name, :string
  end
end
