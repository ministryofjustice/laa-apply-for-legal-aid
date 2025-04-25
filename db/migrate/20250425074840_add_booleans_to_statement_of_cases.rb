class AddBooleansToStatementOfCases < ActiveRecord::Migration[8.0]
  def change
    add_column :statement_of_cases, :upload, :boolean
    add_column :statement_of_cases, :typed, :boolean
  end
end
