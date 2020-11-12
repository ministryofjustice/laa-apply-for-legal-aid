class AddColumnsToCCMSSubmissionHistories < ActiveRecord::Migration[5.2]
  def change
    add_column :ccms_submission_histories, :request, :text
    add_column :ccms_submission_histories, :response, :text
  end
end
