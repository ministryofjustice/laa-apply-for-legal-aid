class UpdateRegularTransactions < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      change_table :regular_transactions, bulk: true do |t|
        t.string :description
        t.belongs_to :owner, polymorphic: true, type: :uuid
      end
    end
  end
end
