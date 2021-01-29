class AddTextSearchableToProceedingTypes < ActiveRecord::Migration[6.1]
  def up
    execute 'ALTER TABLE proceeding_types ADD COLUMN textsearchable tsvector'
    execute 'CREATE INDEX textsearch_idx ON proceeding_types USING GIN (textsearchable)'
    ProceedingType.refresh_textsearchable
  end

  def down
    execute 'DROP INDEX textsearch_idx'
    execute 'ALTER TABLE proceeding_types DROP COLUMN textsearchable'
  end
end
