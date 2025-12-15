namespace :migrate do
  desc "AP-6388 migrate provider_step from remove_opponent to opponent_types/has_other_opponents"

  task :remove_opponent_step, [:dry_run] => :environment do |_task, args|
    dry_run = args.dry_run != "false"

    application_ids = LegalAidApplication.where(provider_step: "remove_opponent").ids
    applications =  LegalAidApplication.where(id: application_ids)

    Rails.logger.info "Migrating legal aid applications: setting provider_step: remove_opponent"
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Remove opponent page count            : #{applications.count}"
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="

    ActiveRecord::Base.transaction do
      applications.each do |app|
        provider_step = app.opponents.any? ? "has_other_opponents" : "opponent_types"
        if dry_run
          Rails.logger.info "[DRY-RUN] will update #{app.application_ref}, from \"#{app.provider_step}\" to \"#{provider_step}\""
        else
          Rails.logger.info "[UPDATING] #{app.application_ref}, from \"#{app.provider_step}\" to \"#{provider_step}\""
          app.update_columns(provider_step:)
        end
      end
      raise StandardError, "Not all applications updated" if applications.where(provider_step: "remove_opponent").any?
    end

    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Rails.logger.info "Applications updated to has_other_opponents step   : #{applications.where(provider_step: 'has_other_opponents').count}"
    Rails.logger.info "Applications updated to opponent_types step   : #{applications.where(provider_step: 'opponent_types').count}"
    Rails.logger.info "Applications not updated: #{applications.where(provider_step: 'remove_opponent').count}"
    Rails.logger.info "----------------------------------------"
  end
end
