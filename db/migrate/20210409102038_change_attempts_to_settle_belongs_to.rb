class ChangeAttemptsToSettleBelongsTo < ActiveRecord::Migration[6.1]
  def up
    add_belongs_to :attempts_to_settles, :application_proceeding_type, foreign_key: true, null: false, type: :uuid
    remove_belongs_to :attempts_to_settles, :legal_aid_application
  end

  def down
    add_belongs_to :attempts_to_settles, :legal_aid_application, foreign_key: true, null: false, type: :uuid
    remove_belongs_to :attempts_to_settles, :application_proceeding_type
  end
end
