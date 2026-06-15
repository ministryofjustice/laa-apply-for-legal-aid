# To run this task, use the following command: rake migrate:applicant_entering_means
namespace :migrate do
  desc "AP-6909 migrate provider_step from applicant_entering_means to citizen_entering_means"
  task :applicant_entering_means, [:dry_run] => :environment do |_task, args|
    dry_run = args.dry_run != "false"

    state_machines = BaseStateMachine.where(aasm_state: "applicant_entering_means")
    state_machines_count = state_machines.count

    Rails.logger.info "Migrating state from applicant_entering_means to citizen_entering_means"
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "applicant_entering_means count: #{state_machines.where(aasm_state: 'applicant_entering_means').count}"
    Rails.logger.info "citizen_entering_means count  : #{state_machines.where(aasm_state: 'citizen_entering_means').count}"
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="

    ActiveRecord::Base.transaction do
      state_machines.each do |sm|
        if dry_run
          Rails.logger.info "[DRY-RUN] This will update #{sm.legal_aid_application.application_ref}"
        else
          Rails.logger.info "[UPDATING] #{sm.legal_aid_application.application_ref}"
          sm.update!(aasm_state: "citizen_entering_means")
        end
      end
      raise StandardError, "Not all applications updated. None saved!" if state_machines.where(aasm_state: "applicant_entering_means").any? && !dry_run
    end

    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Rails.logger.info "State updated                 : #{state_machines_count - state_machines.where(aasm_state: 'applicant_entering_means').count}"
    Rails.logger.info "----------------------------------------"
  end
end
