class UpdateStates < ActiveRecord::Migration[6.0]
  def up
    MigrationHelpers::StateChanger.new(dummy_run: false).up
  end

  def down
    MigrationHelpers::StateChanger.new(dummy_run: false).down
  end
end
