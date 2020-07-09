class AddUniqueIndexToActorPermissions < ActiveRecord::Migration[6.0]
  def change
    add_index :actor_permissions, %i[permittable_type permittable_id permission_id], name: 'actor_permissions_unqiueness', unique: true
  end
end
