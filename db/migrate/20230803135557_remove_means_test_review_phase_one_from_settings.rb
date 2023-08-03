class RemoveMeansTestReviewPhaseOneFromSettings < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :settings, :means_test_review_phase_one, :boolean, null: false, default: false
    end
  end
end
