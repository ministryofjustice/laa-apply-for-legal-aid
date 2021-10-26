class AddProceedingsToAttemptsToSettle < ActiveRecord::Migration[6.1]
  def change
    add_reference :attempts_to_settles, :proceeding,  foreign_key: true, type: :uuid
    add_reference :chances_of_successes, :proceeding, foreign_key: true, type: :uuid
  end
end
