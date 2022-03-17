class MarkPurgeableService
  def self.call
    new.call
  end

  def initialize
    @threshold_date = 23.months.ago
  end

  def call
    # update all records whose updated date is more than 23 months ago and set the purgeable_on date to the updated date + 2 years.
    connection = ActiveRecord::Base.connection.raw_connection
    connection.prepare("mark_recs_purgeable", "UPDATE legal_aid_applications SET purgeable_on = date_trunc('day', updated_at) + interval '730' day WHERE updated_at < $1")
    connection.exec_prepared("mark_recs_purgeable", [@threshold_date])
  end
end
