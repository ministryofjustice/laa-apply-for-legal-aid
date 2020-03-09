class AddManuallyReviewAllCasesToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :manually_review_all_cases, :boolean, default: true
  end
end
