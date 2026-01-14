namespace :ccms do
  desc "Restart CCMS submissions after CCMS have been turned off"
  task restart_submissions: :environment do
    CCMS::TurnOnSubmissionsWorker.perform_async
  end
end
