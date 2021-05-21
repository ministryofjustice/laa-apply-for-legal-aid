class AdminReports < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_reports, id: :uuid do |t|
      t.timestamps
    end
  end
end
