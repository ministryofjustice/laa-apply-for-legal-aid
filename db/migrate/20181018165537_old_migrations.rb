class OldMigrations < ActiveRecord::Migration[5.2]
  REQUIRED_VERSION = 20181018165537
  def up
    if ActiveRecord::Migrator.current_version < REQUIRED_VERSION
      error_message = <<~OLDMIGRATIONERROR
        Due to old migrations requiring gems we no longer use migrations
        prior to this have been deleted, this will not affect production
        environments, but will affect developers re-creating their local
        databases.
        We recommend using the newer `rails db:reset`, this will run drop,
        create, schema:load, and seed.  If you need to run `rails db:migrate`
        then you will need to run `rails db:schema:load` must be run first
      OLDMIGRATIONERROR
      raise StandardError, error_message
    end
  end
end
