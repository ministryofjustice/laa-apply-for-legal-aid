namespace :purge do
  desc 'Mark old records as purgeable'
  task mark: :environment do
    MarkPurgeableService.call
  end

  desc 'Destroy records marked as purgeable'
  task destroy: :environment do
    DestroyPurgeableService.call
  end
end
