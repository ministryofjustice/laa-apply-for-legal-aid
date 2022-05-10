class UpdateProviderAddCookieEnabled < ActiveRecord::Migration[6.1]
  def change
    add_column :providers, :cookies_enabled, :boolean, default: true
  end
end
