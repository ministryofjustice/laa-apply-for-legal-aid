class AddQuestionsToFeedback < ActiveRecord::Migration[7.2]
  def change
    add_column :feedbacks, :done_all_needed_reason, :text
    add_column :feedbacks, :difficulty_reason, :text
    add_column :feedbacks, :satisfaction_reason, :text
    add_column :feedbacks, :time_taken_satisfaction, :integer
    add_column :feedbacks, :time_taken_satisfaction_reason, :text

    add_column :feedbacks, :contact_name, :string
    add_column :feedbacks, :contact_email, :string
  end
end
