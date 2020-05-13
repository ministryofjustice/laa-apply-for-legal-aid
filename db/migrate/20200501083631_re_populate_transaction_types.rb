class RePopulateTransactionTypes < ActiveRecord::Migration[6.0]
  def up
    # rerun population method to add new excluded benefits record
    TransactionType.connection.schema_cache.clear!
    TransactionType.reset_column_information
    Populators::TransactionTypePopulator.call
  end

  def down
    TransactionType.find_by(name: 'excluded_benefits').destroy!
  end
end
