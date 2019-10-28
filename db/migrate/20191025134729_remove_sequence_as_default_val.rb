class RemoveSequenceAsDefaultVal < ActiveRecord::Migration[5.2]
  def up
    # this is to remove the default value of nextval('case_proceeding_sequence') that may have been added as part of db:seeds
    change_column :application_proceeding_types, :proceeding_case_id, :integer, default: nil
  end

  def down
    # nothing to do here.
  end
end
