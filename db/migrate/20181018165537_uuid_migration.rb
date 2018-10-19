require 'webdack/uuid_migration/helpers'

class UuidMigration < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        primary_key_to_uuid :addresses
        primary_key_to_uuid :application_proceeding_types
      end

      dir.down do
        raise ActiveRecord::IrreversibleMigration
      end
    end
  end
end
