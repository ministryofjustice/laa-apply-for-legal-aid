class DropSequence < ActiveRecord::Migration[5.2]
  def up
    execute 'DROP SEQUENCE IF EXISTS case_proceeding_sequence'
  end

  def down
    # nothing to do here
  end
end
