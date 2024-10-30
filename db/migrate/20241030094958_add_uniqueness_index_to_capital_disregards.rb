class AddUniquenessIndexToCapitalDisregards < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index(:capital_disregards, [:legal_aid_application_id, :name], unique: true, algorithm: :concurrently)
  end
end
