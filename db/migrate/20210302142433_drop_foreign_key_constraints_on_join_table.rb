class DropForeignKeyConstraintsOnJoinTable < ActiveRecord::Migration[6.1]
  def up
    remove_foreign_key :proceeding_type_scope_limitations, :proceeding_types if foreign_key_exists?(:proceeding_type_scope_limitations, :proceeding_types)

    remove_foreign_key :proceeding_type_scope_limitations, :scope_limitations if foreign_key_exists?(:proceeding_type_scope_limitations, :scope_limitations)
  end

  def down
    nil
  end
end
