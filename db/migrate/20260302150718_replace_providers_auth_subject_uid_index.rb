class ReplaceProvidersAuthSubjectUidIndex < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :providers, [:silas_id, :auth_provider], unique: true, algorithm: :concurrently
  end
end
