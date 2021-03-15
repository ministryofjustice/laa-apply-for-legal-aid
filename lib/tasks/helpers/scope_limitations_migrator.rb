class ScopeLimitationsMigrator
  def initialize
    @verbose_log = []
  end

  def self.call
    new.call
  end

  def call
    LegalAidApplication.pluck(:id).each { |laa_id| process(laa_id) }
    @verbose_log.each { |vl| puts vl }
  end

  private

  def log(msg)
    @verbose_log << msg
  end

  def process(laa_id)
    laa = LegalAidApplication.find(laa_id)
    log "Processing LegalAidApplication #{laa.id} - #{laa.application_ref}"
    if laa.proceeding_types.empty?
      log '  No proceeding types - no action taken'
      return
    end
    migrate!(laa)
  end

  def migrate!(laa)
    laa.application_proceeding_types.each { |apt| process_apt(laa, apt) }
  end

  def process_apt(laa, apt)
    laa.application_scope_limitations.each do |asl|
      log "  Processing ASL #{asl.id}"
      klass = asl.substantive? ? AssignedSubstantiveScopeLimitation : AssignedDfScopeLimitation
      existing_record = klass.find_by(application_proceeding_type_id: apt.id, scope_limitation_id: asl.scope_limitation_id)
      if existing_record.nil?
        rec = klass.create!(application_proceeding_type_id: apt.id, scope_limitation_id: asl.scope_limitation_id)
        log "    Created #{klass} id: #{rec.id} apt_id: #{apt.id} sl_id: #{asl.scope_limitation_id} "
      else
        log "    >>>>>>>>>> #{klass} record already exists for apt_id #{apt.id} and sl_id #{asl.scope_limitation_id}"
      end
    end
  end
end
# :nocov:
