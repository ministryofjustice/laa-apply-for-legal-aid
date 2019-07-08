class AddRelationshipToDependant < ActiveRecord::Migration[5.2]
  def change
    add_column :dependants, :relationship, :string
  end
end
