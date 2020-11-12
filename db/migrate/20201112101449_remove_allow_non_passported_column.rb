class RemoveAllowNonPassportedColumn < ActiveRecord::Migration[6.0]
  def change
    remove_column :settings, :allow_non_passported_route, :boolean
  end
end
