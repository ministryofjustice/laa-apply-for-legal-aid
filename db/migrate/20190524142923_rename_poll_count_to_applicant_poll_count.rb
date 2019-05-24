class RenamePollCountToApplicantPollCount < ActiveRecord::Migration[5.2]
  def change
    rename_column :ccms_submissions, :poll_count, :applicant_poll_count
  end
end
