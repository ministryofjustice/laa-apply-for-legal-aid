namespace :state_machine do
  desc 'Migrate state from legal_aid_application into state_machine_proxies into the database (prefix with SEEDS_DRY_MODE=false to disable DRY mode)'
  task migrate: :environment do
    ENV['SEEDS_DRY_MODE'] = 'true' if ENV['SEEDS_DRY_MODE'].blank?
    @dry_run = ENV['SEEDS_DRY_MODE'] != 'false'
    @counts = { dry_run: @dry_run, processed: 0, fail: 0, output: [] }
    run_non_destructive_change_checks
    migrate_states
    pp @counts.except(:output)
    run_non_destructive_change_checks if @dry_run
  end

  private

  def migrate_states
    ActiveRecord::Base.transaction do
      LegalAidApplication.all.each do |application|
        process_application(application)
      end
      cancel_migration = rollback_transactions?
      raise ActiveRecord::Rollback if cancel_migration
      raise 'DO NOT PASS GO' if cancel_migration && !@dry_run
    end
  end

  def process_application(application)
    @counts[:processed] += 1
    @type = application.passported? ? 'PassportedStateMachine' : 'NonPassportedStateMachine'
    application.create_state_machine!(type: @type, aasm_state: application.read_attribute(:state))
    log "Created #{@type} state machine for application: #{application.id} with an aasm_state of `#{application.read_attribute(:state)}`", stdout: false
  rescue StandardError
    log "Failed to create a #{@type} state machine for application: #{application.id} with an aasm_state of `#{application.read_attribute(:state)}`"
    @counts[:fail] += 1
  end

  def rollback_transactions?
    !all_states_match? || @counts[:fail].positive? || @dry_run
  end

  def all_states_match?
    LegalAidApplication.all.map { |laa| laa.state.eql?(laa.state_machine_proxy.aasm_state) }.all?
  end

  def log(message, stdout: true)
    log_parts = [message]
    log_parts << '[DRY RUN]' if @dry_run
    output = log_parts.join(' ')
    @counts[:output] << [output]
    Rails.logger.info output
    puts output if stdout
  end

  def run_non_destructive_change_checks
    raise 'unexpected changes made' if BaseStateMachine.count.positive?
  end
end
