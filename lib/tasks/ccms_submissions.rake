namespace :ccms_submissions do
  desc "Turn off ccms submissions"
  task turn_off: :environment do
    ScheduledCCMSSubmissionsToggleJob.perform_later(:turn_off)
  end

  desc "Turn off ccms submissions"
  task turn_on: :environment do
    ScheduledCCMSSubmissionsToggleJob.perform_later(:turn_on)
  end

  desc "Send slack reminder to turn on ccms submissions"
  task reminder_turn_on: :environment do
    ScheduledCCMSSubmissionsToggleJob.perform_later(:alert)
  end
end
