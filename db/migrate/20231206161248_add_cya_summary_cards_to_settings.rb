class AddCyaSummaryCardsToSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :settings, :cya_summary_cards, :boolean, null: false, default: false
  end
end
