class AddArchivedAtToTransactionTypes < ActiveRecord::Migration[5.2]
  def up
    add_column(:transaction_types, :archived_at, :datetime)
    Populators::TransactionTypePopulator.call(:without_income)
  end

  def down
    remove_column(:transaction_types, :archived_at, :datetime)
  end
end
