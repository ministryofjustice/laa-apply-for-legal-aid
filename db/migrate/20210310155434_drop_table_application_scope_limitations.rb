class DropTableApplicationScopeLimitations < ActiveRecord::Migration[6.1]
  def change
    drop_table :application_scope_limitations
  end
end
