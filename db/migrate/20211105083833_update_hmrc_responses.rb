class UpdateHMRCResponses < ActiveRecord::Migration[6.1]
  def change
    add_reference :hmrc_responses, :legal_aid_application, foreign_key: true, null: true, type: :uuid
    rename_column :hmrc_responses, :application_id, :submission_id
    add_column :hmrc_responses, :url, :string
  end
end
