class RemoveFirstNameLastNameFromOpponents < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_columns :opponents, :first_name, :last_name }
  end
end
