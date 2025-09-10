namespace :migrate do
  #
  # The new DWP flow logic will go to various new controllers/pages/forms based on partner existence, positive, negative
  # (or unavailable) response from DWP Benefit checker. Rather than determine what step each application should be
  #  we force them back to the check provider answers page. Once they click continue from there they will
  #  1. if they have a positive response already go to the new positive response screen
  #  2. if they hava e negative response already they will go to the new negative response page, allowing them to specify it is incorrect if desired
  #  3. if DWP is down they will be offered the new fallback flow
  #  4. if they go from the CYA page to amend applicant details, then progress, then the DWP check will be performed again.
  #
  #  NOTE: This will also updated discarded and voided applications.
  #
  desc "AP-6215 migrate provider_step from old DWP pages to new prior to them"
  task :dwp_page_steps, [:dry_run] => :environment do |_task, args|
    dry_run = args.dry_run != "false"

    dwp_benefit_checker_steps = %w[check_benefits confirm_dwp_non_passported_applications]
    application_ids = LegalAidApplication.where(provider_step: dwp_benefit_checker_steps).ids
    applications =  LegalAidApplication.where(id: application_ids)

    Rails.logger.info "Migrating legal aid applications: setting provider_step: check_provider_answers"
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Check benefits page count            : #{applications.where(provider_step: 'check_benefits').count}"
    Rails.logger.info "Confirm DWP non-passported page count: #{applications.where(provider_step: 'confirm_dwp_non_passported_applications').count}"
    Rails.logger.info "states grouping                      : #{applications.joins(:state_machine).order(state_machine_proxies: { aasm_state: :asc }).group(state_machine_proxies: :aasm_state).count}"
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Benchmark.benchmark do |bm|
      bm.report("Migrate:") do
        ActiveRecord::Base.transaction do
          applications.each do |app|
            if dry_run
              Rails.logger.info "[DRY-RUN] will update #{app.application_ref}, from \"#{app.provider_step}\" to \"check_provider_answers\", and state: #{app.state} to \"checking_applicant_details\""
            else
              Rails.logger.info "[UPDATING] #{app.application_ref}, from \"#{app.provider_step}\" to \"check_provider_answers\", and state: #{app.state} to \"checking_applicant_details\""
              app.state_machine_proxy.update_columns(aasm_state: "checking_applicant_details")
              app.update_columns(provider_step: "check_provider_answers") # this prevents the updated_at date being changed and delaying purging of stale records
            end
          end
          raise StandardError, "Not all applications updated. None saved!" if applications.where(provider_step: dwp_benefit_checker_steps).any?
        end
      end
    end
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Rails.logger.info "Applications step updated    : #{applications.where(provider_step: 'check_provider_answers').count}"
    Rails.logger.info "Applications state updated    : #{applications.joins(:state_machine).where(state_machine_proxies: { aasm_state: 'checking_applicant_details' }).count}"
    Rails.logger.info "Applications not updated: #{applications.where(provider_step: dwp_benefit_checker_steps).count}"
    Rails.logger.info "----------------------------------------"
  end
end
