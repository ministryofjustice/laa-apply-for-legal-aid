class AddTypeOpponents < ActiveRecord::Migration[7.0]
  def change
    add_column :opponents, :type, :string, default: "ApplicationMeritsTask::Opponent::Individual"
    add_column :opponents, :organisation_name, :string
    add_column :opponents, :organisation_type, :string
  end
end
