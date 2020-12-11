class AddCashPaymentFlagToSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :settings, :allow_cash_payment, :boolean, null: false, default: false
  end
end
