class DigestExtractor
  def self.call
    new.call
  end

  def initialize
    @start_time = Time.zone.now
    @last_run_date = Setting.setting.digest_extracted_at
    @application_ids = LegalAidApplication.where(updated_at: @last_run_date..Time.zone.now).pluck(:id)
  end

  def call
    @application_ids.each { |laa_id| ApplicationDigest.create_or_update!(laa_id) }
    Setting.setting.update!(digest_extracted_at: @start_time)
  end
end
