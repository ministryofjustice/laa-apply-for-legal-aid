class JobQueue
  END_OF_TIME = Time.zone.local(9999, 12, 31, 23, 59, 59)

  # returns true if the named class is queued for execution within its
  # default delay time
  #
  def self.enqueued?(klass)
    next_job_due(klass) < Time.current + klass::DEFAULT_DELAY
  end

  def self.next_job_due(klass)
    ss = Sidekiq::ScheduledSet.new
    enqueued_jobs = ss.select do |job|
      job.item['queue'] == klass.queue_name &&
        job.item['wrapped'] == klass.to_s
    end
    return END_OF_TIME if enqueued_jobs.empty?

    next_due = enqueued_jobs.map(&:score).min
    Time.zone.at(next_due)
  end

  # method used for manual diagnosis only
  # :nocov:
  # rubocop:disable Rails/Output
  def self.list
    format_pattern = '%<jobname>30s    %<due>s'
    ss = Sidekiq::ScheduledSet.new

    puts format(format_pattern, jobname: 'Job name', due: 'Due')
    puts format(format_pattern, jobname: '========', due: '===')
    ss.each do |job|
      next if job_name(job).blank?

      puts  format(format_pattern, jobname: job_name(job), due: scheduled_time(job))
    end
  end
  # rubocop:enable Rails/Output

  def self.job_name(job)
    job.item['wrapped']
  end

  def self.scheduled_time(job)
    Time.zone.at(job.score)
  end
  # :nocov:

  private_class_method :next_job_due, :job_name, :scheduled_time
end
