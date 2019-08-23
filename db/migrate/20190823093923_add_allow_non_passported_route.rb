class AddAllowNonPassportedRoute < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :allow_non_passported_route, :boolean, null: false, default: true
  end
end
