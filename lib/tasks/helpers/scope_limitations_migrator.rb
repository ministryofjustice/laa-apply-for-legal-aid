# :nocov:
class ScopeLimitationsMigrator
  def initialize(dummy_run, verbose)
    @dummy_run = dummy_run
    @verbose = verbose
    @verbose_log = []
    log '**** DUMMY RUN ****'
  end

  def self.call(dummy_run:, verbose:)
    new(dummy_run, verbose).call
  end

  def call
    ApplicationProceedingTypesScopeLimitation.delete_all
    LegalAidApplication.pluck(:id).each { |laa_id| process(laa_id) }
  rescue StandardError => e
    puts "#{e.class}:: #{e.message}"
    @verbose_log.each { |vl| puts vl } if @verbose
  end

  private

  def log(msg)
    @verbose_log << msg
  end

  def process(laa_id)
    laa = LegalAidApplication.find(laa_id)
    return if laa.proceeding_types.empty?

    return unless laa.application_proceeding_types.first.assigned_scope_limitations.empty? # migration already happened

    migrate!(laa)
  end

  def migrate!(laa)
    log "Processing LegalAidApplication #{laa.id}"
    log "****** multiple proceeding types ******" if laa.application_proceeding_types.size > 1
    laa.application_proceeding_types.each { |apt| process_apt(laa, apt) }
  end

  def process_apt(laa, apt)
    laa.application_scope_limitations.each do |asl|
      log "    Processing ASL #{asl.id}"
      klass = asl.substantive? ? AssignedSubstantiveScopeLimitation : AssignedDfScopeLimitation
      begin
        rec = klass.create!(application_proceeding_type_id: apt.id, scope_limitation_id: asl.scope_limitation_id)
        log "    Created #{klass} id: #{rec.id} apt_id: #{apt.id} sl_id: #{asl.scope_limitation_id} "
      rescue ActiveRecord::RecordNotUnique
        puts ">>>>>>>>>>>>>>>>>>>>> Tried to write duplcate record <<<<<<<<<<<<<<<<<"
      end

    end
  end
end
# :nocov:
