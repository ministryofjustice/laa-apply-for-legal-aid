class RunScopeLimitationsMigrator < ActiveRecord::Migration[6.1]
  def up
    require Rails.root.join('db/migration_helpers/scope_limitations_migrator')
    ScopeLimitationsMigrator.call
  end

  def down
    nil
  end
end
