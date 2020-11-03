class AddCasePollCountToCCMSSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :ccms_submissions, :case_poll_count, :integer, default: 0
  end
end
