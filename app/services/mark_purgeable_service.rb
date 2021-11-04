class MarkPurgeableService
  def self.call
    new.call
  end

  def call
    connection = ActiveRecord::Base.connection.raw_connection
    connection.prepare('mark_recs_purgeable', 'UPDATE legal_aid_applications SET purgeable = true WHERE updated_at < $1')
    connection.exec_prepared('mark_recs_purgeable', [23.months.ago])
  end
end
