class AddSubmissionFeedbackToFeedbacks < ActiveRecord::Migration[6.1]
  def change
    add_column :feedbacks, :submission_feedback, :boolean, null: false, default: false
  end
end
