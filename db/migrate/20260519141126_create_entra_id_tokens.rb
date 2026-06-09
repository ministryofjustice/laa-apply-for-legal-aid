class CreateEntraIdTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :entra_id_tokens, id: :uuid do |t|
      t.belongs_to :provider, null: false, foreign_key: true, type: :uuid

      t.text :id_token
      t.text :access_token
      t.text :refresh_token
      t.string :scope
      t.datetime :access_token_expires_at

      t.timestamps
    end
  end
end
