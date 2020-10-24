class AddBrowserDetailsToDebug < ActiveRecord::Migration[6.0]
  def change
    add_column :debugs, :browser_details, :string
  end
end
