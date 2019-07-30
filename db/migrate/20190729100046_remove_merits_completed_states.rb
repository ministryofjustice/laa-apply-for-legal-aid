class RemoveMeritsCompletedStates < ActiveRecord::Migration[5.2]
  ORIGINAL_STATE = 'merits_completed'.freeze
  NEW_STATE = 'assessment_submitted'.freeze

  def up
    LegalAidApplication.where(state: ORIGINAL_STATE).update_all(state: NEW_STATE)
  end

  def down
    LegalAidApplication.where(state: NEW_STATE).update_all(state: ORIGINAL_STATE)
  end
end
