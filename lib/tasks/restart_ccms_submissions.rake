namespace :ccms do
  desc 'Restart CCMS submissions after CCMS have been turned off'
  task restart_submissions: :environment do
    CCMSRestartSubmissions.call
  end
end
