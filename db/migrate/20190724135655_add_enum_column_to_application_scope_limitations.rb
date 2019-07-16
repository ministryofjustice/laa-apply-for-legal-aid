class AddEnumColumnToApplicationScopeLimitations < ActiveRecord::Migration[5.2]
  def change
    add_column :application_scope_limitations, :substantive, :boolean, default: true
  end
end
