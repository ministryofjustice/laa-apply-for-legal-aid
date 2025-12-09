class CreateDatastoreSubmissions < ActiveRecord::Migration[8.1]
  def change
    create_table :datastore_submissions, id: :uuid do |t|
      t.integer :status
      t.text :body
      t.jsonb :headers
      t.belongs_to :legal_aid_application, null: false, foreign_key: true, type: :uuid
      t.timestamps
    end
  end
end
