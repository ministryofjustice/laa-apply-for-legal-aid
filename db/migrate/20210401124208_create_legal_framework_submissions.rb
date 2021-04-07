class CreateLegalFrameworkSubmissions < ActiveRecord::Migration[6.1]
  def change
    create_table :legal_framework_submissions, id: :uuid do |t|
      t.references :legal_aid_application, foreign_key: true, type: :uuid
      t.uuid :request_id
      t.string :error_message
      t.text :result
      t.timestamps
    end
  end
end
