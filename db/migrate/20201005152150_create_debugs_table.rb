class CreateDebugsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :debugs, id: :uuid do |t|
      t.string :debug_type
      t.string :legal_aid_application_id
      t.string :session_id
      t.text :session
      t.string :auth_params
      t.string :callback_params
      t.string :callback_url
      t.string :error_details

      t.timestamps
    end
  end
end
