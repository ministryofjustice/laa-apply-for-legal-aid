class CreateActorPermissions < ActiveRecord::Migration[6.0]
  def change
    create_table :actor_permissions, id: :uuid do |t|
      t.references :permittable, polymorphic: true, index: true, type: :uuid
      t.uuid :permission_id
      t.timestamps
    end
  end
end
