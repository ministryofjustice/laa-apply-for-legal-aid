class AddOmniAuthColumnsIndexToProviders < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :providers, [:auth_subject_uid, :auth_provider], unique: true, algorithm: :concurrently
  end
end
