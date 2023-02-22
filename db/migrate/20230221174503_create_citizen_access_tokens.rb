class CreateCitizenAccessTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :citizen_access_tokens, id: :uuid do |t|
      t.references :legal_aid_application, type: :uuid, foreign_key: { on_delete: :cascade }, null: false
      t.string :token, null: false, default: ""
      t.date :expires_on, null: false

      t.timestamps
    end
  end
end
