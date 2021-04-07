class CreateLegalFrameworkSubmissionHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :legal_framework_submission_histories, id: :uuid do |t|
      t.uuid :submission_id
      t.string :url
      t.string :http_method
      t.text :request_payload
      t.integer :http_response_status
      t.text :response_payload
      t.string :error_message
      t.string :error_backtrace
      t.timestamps
    end
  end
end
