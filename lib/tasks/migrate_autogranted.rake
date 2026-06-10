namespace :migrate do
  desc "AP-7019: Populate involved children first and last names from their full name"
  # Rake task to populate autogranted database field.
  # Call with "rake migrate:migrate_autogranted[mock]"
  # e.g. rake "migrate:migrate_autogranted[false]"
  # Running with mock=true will output the number of records to be updated without actually updating any
  # (to allow for testing).

  task :migrate_autogranted, %i[mock] => :environment do |task, args|
    mock = args[:mock].to_s.downcase.strip != "false"
    Rails.logger.info "#{task}: mock=#{mock}"
    applications = LegalAidApplication.where.not(merits_submitted_at: nil).where(autogranted: nil)
    applications_count = applications.count
    Rails.logger.info "#{task}: Updating #{applications_count} applications"
    applications.in_batches do |batch|
      batch.each do |application|
        autogranted = application.auto_grant_special_children_act?
        next if mock

        application.autogranted = autogranted
        application.save!(touch: false) # this prevents the updated_at date being changed and delaying purging of stale records
      end
    end
    Rails.logger.info "#{task}: #{applications_count} applications updated"
    Rails.logger.info "#{task}: #{LegalAidApplication.where.not(merits_submitted_at: nil).where(autogranted: nil).count} submitted applications without an autogranted value"
  end
end
