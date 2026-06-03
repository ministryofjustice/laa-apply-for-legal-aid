class AddReportOnlyToAdminUser < ActiveRecord::Migration[8.1]
  def change
    add_column :admin_users, :report_only, :boolean, default: true
  end
end
