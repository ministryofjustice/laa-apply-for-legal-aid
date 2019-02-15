class AddUploaderToStatementOfCase < ActiveRecord::Migration[5.2]
  def change
    add_reference :statement_of_cases, :provider_uploader, type: :uuid, index: true
    add_foreign_key :statement_of_cases, :providers, column: :provider_uploader_id
  end
end
