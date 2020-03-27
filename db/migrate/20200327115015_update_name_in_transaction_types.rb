class UpdateNameInTransactionTypes < ActiveRecord::Migration[6.0]
  def up
    TransactionType.where(name: 'pension').update_all(name: 'private_pension')
  end

  def down
    TransactionType.where(name: 'private_pension').update_all(name: 'pension')
  end
end
