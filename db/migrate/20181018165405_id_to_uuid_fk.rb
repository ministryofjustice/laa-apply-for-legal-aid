require 'webdack/uuid_migration/helpers'

class IdToUuidFk < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        primary_key_and_all_references_to_uuid :applicants
        primary_key_and_all_references_to_uuid :legal_aid_applications
        primary_key_and_all_references_to_uuid :proceeding_types
      end

      dir.down do
        raise ActiveRecord::IrreversibleMigration
      end
    end
  end
end
