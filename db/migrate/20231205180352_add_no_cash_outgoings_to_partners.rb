class AddNoCashOutgoingsToPartners < ActiveRecord::Migration[7.1]
  def change
    add_column :partners, :no_cash_outgoings, :boolean
  end
end
