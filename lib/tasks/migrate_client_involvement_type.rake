namespace :migrate do
  desc "AP-6898 migrate provider_step from client_involvement_type to delegated_functions"

  task :migrate_client_involvement_type, [:dry_run] => :environment do |_task, args|
    dry_run = args.dry_run != "false"

    applications = LegalAidApplication.where(provider_step: "client_involvement_type")
    applications_count = applications.count

    Rails.logger.info "Migrating legal aid applications: setting provider_step: delegated_functions"
    Rails.logger.info "------------------------------------------------------------------------------------------------"
    Rails.logger.info "Client involvement type page count: #{applications.count}"
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="

    ActiveRecord::Base.transaction do
      applications.each do |app|
        if dry_run
          Rails.logger.info "[DRY-RUN] will update #{app.application_ref}, from \"#{app.provider_step}\" to \"delegated_functions\""
        else
          Rails.logger.info "[UPDATING] #{app.application_ref}, from \"#{app.provider_step}\" to \"delegated_functions\""
          app.update_columns(provider_step: "delegated_functions")
        end
      end
      raise StandardError, "Not all applications updated" if applications.where(provider_step: "client_involvement_type").any?
    end

    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Rails.logger.info "Applications updated to delegated_functions step  : #{applications_count}"
    Rails.logger.info "------------------------------------------------------------------------------------------------"
  end
end
