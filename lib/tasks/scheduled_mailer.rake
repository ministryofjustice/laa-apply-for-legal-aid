# temp rake file to add missing parameters in existing ScheduledMailer records

namespace :scheduled_mailer do
  task bugfix: :environment do
    ScheduledMailing.all.each do |mailing|
      params = mailing.arguments
      params[1] = mailing.legal_aid_application.applicant.full_name
      mailing.save!
    end
  end
end
