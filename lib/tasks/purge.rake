namespace :purge do
  desc 'Mark old records as purgeable'
  task mark: :environment do
    MarkPurgeableService.call
  end
end
