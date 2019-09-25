class AddColumnsToCcmsSubmissionHistories < ActiveRecord::Migration[5.2]
  def change
      add_column :ccms_submission_histories, :request, :xml
      add_column :ccms_submission_histories, :response, :xml
  end
end
