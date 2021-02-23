class ScopeLimitationsMigrator
  def self.call
    new.call
  end

  def call
    LegalAidApplication.pluck(:id).each { |laa_id| process(laa_id) }
  end

  private

  def process(laa_id)
    laa = LegalAidApplication.find(laa_id)
    return if laa.proceeding_types.empty?

    return unless laa.application_proceeding_types.first.assigned_scope_limitations.empty? # migration already happened

    migrate!(laa)
  end

  def migrate!(laa)
    laa.scope_limitations.each do |sl|
      laa.application_proceeding_types.first.assigned_scope_limitations << sl
    end
  end
end
