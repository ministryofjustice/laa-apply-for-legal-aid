def warning_message(task_name)
  <<~WARNING.freeze
    Digest rake tasks are deactivated on UAT environments, call with
      BYPASS=true rake digest:#{task_name}
    To bypass the UAT block
  WARNING
end

namespace :digest do
  desc "Run DigestExtractor to update application digests"
  task extract: :environment do
    if !HostEnv.staging_or_production? && ENV.fetch("BYPASS", nil).nil?
      Rails.logger.info warning_message("extract")
      next
    end

    DigestExtractor.call
  end

  desc "Run DigestExporter to export digest records to google sheet"
  task export: :environment do
    if !HostEnv.staging_or_production? && ENV.fetch("BYPASS", nil).nil?
      Rails.logger.info warning_message("export")
      next
    end

    DigestExporter.call
  end

  namespace :extraction_date do
    desc "Reset the last_extracted date so that all application_digest records are refreshed"
    task reset: :environment do
      if !HostEnv.staging_or_production? && ENV.fetch("BYPASS", nil).nil?
        Rails.logger.info warning_message("extraction_date")
        next
      end

      Setting.setting.update!(digest_extracted_at: 20.years.ago)
    end
  end
end
