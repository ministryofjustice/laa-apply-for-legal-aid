class AddExistsInCCMSToOpponents < ActiveRecord::Migration[7.0]
  def change
    add_column :opponents, :exists_in_ccms, :boolean, default: false
  end
end
