class AdminReports < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_reports, id: :uuid, &:timestamps
  end
end
