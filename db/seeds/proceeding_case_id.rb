# add proceeding_case_id sequence and alter column to use it
class CreateProceedingCaseId < ActiveRecord::Migration[5.2]
  def self.run
    execute 'CREATE SEQUENCE IF NOT EXISTS case_proceeding_sequence MINVALUE 55000001'

    column = ApplicationProceedingType.columns.detect { |c| c.name == 'proceeding_case_id' }
    execute "ALTER TABLE application_proceeding_types ALTER COLUMN proceeding_case_id SET DEFAULT NEXTVAL('case_proceeding_sequence')" unless /nextval/.match?(column.default_function)
  end
end
CreateProceedingCaseId.run
