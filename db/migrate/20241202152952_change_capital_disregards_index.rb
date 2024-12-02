class ChangeCapitalDisregardsIndex < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    remove_index(:capital_disregards, name: :index_capital_disregards_on_legal_aid_application_id_and_name)
    add_index(:capital_disregards, [:legal_aid_application_id, :name, :mandatory], unique: true, algorithm: :concurrently)
  end
end
