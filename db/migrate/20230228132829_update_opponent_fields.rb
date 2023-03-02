class UpdateOpponentFields < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_columns :opponents, :understands_terms_of_court_order_details, :warning_letter_sent_details, :police_notified_details, :bail_conditions_set_details, type: :string
      remove_columns :opponents, :understands_terms_of_court_order, :warning_letter_sent, :police_notified, :bail_conditions_set, type: :boolean
    end
  end
end
