class UpdateManuallyReviewAllCases < ActiveRecord::Migration[6.0]
  def change
    change_column_default(:settings, :manually_review_all_cases, from: true, to: false)
  end
end
