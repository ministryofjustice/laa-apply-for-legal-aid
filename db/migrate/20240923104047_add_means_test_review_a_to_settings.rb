class AddMeansTestReviewAToSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :settings, :means_test_review_a, :boolean, null: false, default: false
  end
end
