class ScopeLimitationsMigrator
  def initialize(dummy_run, verbose)
    @dummy_run = dummy_run
    @verbose = verbose
    puts '**** DUMMY RUN ****' if @dummy_run && verbose
  end

  def self.call(dummy_run:, verbose:)
    new(dummy_run, verbose).call
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
    puts "Processing LegalAidApplication #{laa.id}" if @verbose
    slids = []
    laa.scope_limitations.each do |sl|
      if slids.include?(sl.id)
        puts "  ignoring SLID #{sl.id} - already processed" if @verbose
        next
      end
      slids << sl.id
      puts "  Adding scope limitation #{sl.id} to APT #{laa.application_proceeding_types.first.id}" if @verbose
      laa.application_proceeding_types.first.assigned_scope_limitations << sl unless @dummy_run
    end
  end
end
