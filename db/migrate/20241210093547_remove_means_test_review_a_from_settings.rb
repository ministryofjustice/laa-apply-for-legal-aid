class RemoveMeansTestReviewAFromSettings < ActiveRecord::Migration[7.2]
  def change
    safety_assured do
      remove_column :settings, :means_test_review_a, :boolean, null: false, default: false
    end
  end
end
