class AddRelationshipToChildToProceedings < ActiveRecord::Migration[7.1]
  def change
    add_column :proceedings, :relationship_to_child, :string
  end
end
