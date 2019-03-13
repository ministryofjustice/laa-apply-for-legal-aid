class CreateRespondents < ActiveRecord::Migration[5.2]
  def change
    create_table :respondents, id: :uuid do |t|
      t.belongs_to :legal_aid_application, foreign_key: true, null: false, type: :uuid
      t.boolean :understands_terms_of_court_order
      t.text    :understands_terms_of_court_order_details
      t.boolean :warning_letter_sent
      t.text    :warning_letter_sent_details
      t.boolean :police_notified
      t.text    :police_notified_details
      t.boolean :bail_conditions_set
      t.text    :bail_conditions_set_details

      t.timestamps
    end
  end
end
