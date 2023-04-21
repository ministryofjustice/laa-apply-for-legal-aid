class CFEComparisonWorker
  include Sidekiq::Worker

  TARGET_HOUR = 20

  def perform
    CFE::CompareResults.call
    CFEComparisonWorker.perform_at(next_run_at)
  end

private

  def next_run_at
    Time.zone.now.advance(days: day_advance).change(hour: 20)
  end

  def day_advance
    Time.zone.now.hour >= TARGET_HOUR ? 1 : 0
  end
end
