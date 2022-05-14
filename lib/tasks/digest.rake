namespace :digest do
  desc "Run DigestExtractor to update application digests"
  task extract: :environment do
    DigestExtractor.call
  end

  desc "Run DigestExporter to export digest records to google sheet"
  task export: :environment do
    DigestExporter.call
  end

  namespace :extraction_date do
    desc "Reset the last_extracted date so that all application_digest records are refreshed"
    task reset: :environment do
      Setting.setting.update!(digest_extracted_at: 20.years.ago)
    end
  end
end
