class RenameRespondentsTableToOpponents < ActiveRecord::Migration[6.1]
  def change
    rename_table :respondents, :opponents
  end
end
