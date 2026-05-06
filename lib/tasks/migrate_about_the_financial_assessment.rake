namespace :migrate do
  desc "AP-6883 migrate provider_step from about_the_financial_assessment to email_address_confirmation"

  task :migrate_email_address_confirmation, [:dry_run] => :environment do |_task, args|
    dry_run = args.dry_run != "false"

    applications = LegalAidApplication.where(provider_step: "about_the_financial_assessments")

    Rails.logger.info "Migrating legal aid applications: setting provider_step: email_address_confirmations"
    Rails.logger.info "------------------------------------------------------------------------------------------------"
    Rails.logger.info "About the financial assessment page count: #{applications.count}"
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="

    ActiveRecord::Base.transaction do
      applications.each do |app|
        if dry_run
          Rails.logger.info "[DRY-RUN] will update #{app.application_ref}, from \"#{app.provider_step}\" to \"email_address_confirmations\""
        else
          Rails.logger.info "[UPDATING] #{app.application_ref}, from \"#{app.provider_step}\" to \"email_address_confirmations\""
          app.update_columns(provider_step: "email_address_confirmations")

          raise StandardError, "Not all applications updated" if applications.where(provider_step: "about_the_financial_assessments").any?
        end
      end
    end

    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Rails.logger.info "Applications updated to email_address_confirmation step  : #{applications.where(provider_step: 'email_address_confirmations').count}"
    Rails.logger.info "------------------------------------------------------------------------------------------------"
  end
end
