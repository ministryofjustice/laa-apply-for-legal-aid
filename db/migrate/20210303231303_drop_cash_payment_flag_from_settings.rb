class DropCashPaymentFlagFromSettings < ActiveRecord::Migration[6.1]
  def up
    remove_column :settings, :allow_cash_payment
  end

  def down
    add_column :settings, :allow_cash_payment, :boolean, null: false, default: false
  end
end
