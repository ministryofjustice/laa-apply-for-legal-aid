class AddOwnerToCashTransaction < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      change_table :cash_transactions, bulk: true do |t|
        t.belongs_to :owner, polymorphic: true, type: :uuid
      end
    end
  end
end
