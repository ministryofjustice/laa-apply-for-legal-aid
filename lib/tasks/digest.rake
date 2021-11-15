namespace :digest do
  desc 'Run DigestExtractor to update application digests'
  task extract: :environment do
    DigestExtractor.call
  end
end
