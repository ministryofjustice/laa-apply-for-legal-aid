class RemoveOpponentsTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :opponents
  end
end
