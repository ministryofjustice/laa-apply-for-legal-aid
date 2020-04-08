class AddDifficultyToFeedback < ActiveRecord::Migration[6.0]
  def change
    add_column :feedbacks, :difficulty, :integer
  end
end
