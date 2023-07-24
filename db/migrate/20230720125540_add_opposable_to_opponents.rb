class AddOpposableToOpponents < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :opponents, :opposable, polymorphic: true, index: { unique: true, algorithm: :concurrently }, type: :uuid
  end
end
