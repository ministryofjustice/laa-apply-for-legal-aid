class AddPollCountToCCMSSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :ccms_submissions, :poll_count, :integer, default: 0
  end
end
