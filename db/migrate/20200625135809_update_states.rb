class UpdateStates < ActiveRecord::Migration[6.0]
  def up
    MigrationHelpers::StateChanger.new(dummy_run: true).up
  end

  def down
    MigrationHelpers::StateChanger.new(dummy_run: true).down
  end
end
