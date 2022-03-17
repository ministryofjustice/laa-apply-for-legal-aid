namespace :digest do
  desc "Run DigestExtractor to update application digests"
  task extract: :environment do
    DigestExtractor.call
  end

  desc "Run DigestExporter to export digest records to google sheet"
  task export: :environment do
    DigestExporter.call
  end
end
