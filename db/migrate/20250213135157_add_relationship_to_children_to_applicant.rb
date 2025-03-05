class AddRelationshipToChildrenToApplicant < ActiveRecord::Migration[7.2]
  def change
    add_column :applicants, :relationship_to_children, :string
  end
end
