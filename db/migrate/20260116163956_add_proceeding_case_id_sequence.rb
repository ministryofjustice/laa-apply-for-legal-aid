class AddProceedingCaseIdSequence < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      # 1. Create the sequence (idempotent)
      # CACHE 100 reduces disk I/O for high-concurrency inserts and the cache values are only lost if there is a crash
      execute <<~SQL
        CREATE SEQUENCE IF NOT EXISTS proceeding_case_id_seq
        OWNED BY proceedings.proceeding_case_id
        START WITH 55000000 INCREMENT BY 1 MINVALUE 55000000 NO MAXVALUE CACHE 100;
      SQL

      # 2. Attach the sequence as the column default
      execute <<~SQL
        ALTER TABLE proceedings
        ALTER COLUMN proceeding_case_id
        SET DEFAULT nextval('proceeding_case_id_seq');
      SQL

      # 3. Set sequence to MAX(proceeding_case_id) + 1 or 55_000_000 (loweset number allowed by CCMS), whichever is higher
      execute <<~SQL
        SELECT setval(
          'proceeding_case_id_seq',
          GREATEST(
            (SELECT COALESCE(MAX(proceeding_case_id), 0) + 1 FROM proceedings),
            55000000
          )
        );
      SQL
    end
  end

  def down
    safety_assured do
      # 1. Remove the sequence as the column default
      execute <<~SQL
        ALTER TABLE proceedings
        ALTER COLUMN proceeding_case_id
        DROP DEFAULT;
      SQL

      # 2. Drop the sequence
      execute <<~SQL
        DROP SEQUENCE IF EXISTS proceeding_case_id_seq;
      SQL
    end
  end
end
