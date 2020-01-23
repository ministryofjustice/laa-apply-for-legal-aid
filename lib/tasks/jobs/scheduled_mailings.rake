desc 'Scan scheduled mailing table and send due mails'
task scheduled_mailings: :environment do
  ScheduledMailingsDeliveryJob.perform_later
end
