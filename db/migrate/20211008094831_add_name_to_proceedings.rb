class AddNameToProceedings < ActiveRecord::Migration[6.1]
  # rubocop:disable Rails/NotNullColumn
  # Disabling this as the table is currently not in use so a non-null column can be
  # safely added without a default. Defaults are not set for any other non-null
  # columns on this table so it would be strange to arbitrarily add one now
  def change
    add_column :proceedings, :name, :string, null: false
  end
  # rubocop:enable Rails/NotNullColumn
end
