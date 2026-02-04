namespace :migrate do
  desc "EL-6583: Delete applicants that are not associated with a LegalAidApplication"
  # Rake task to delete applicants that are not associated with a LegalAidApplication.
  # Call with "rake migrate:delete_orphan_applicants[mock]"
  # e.g. rake "migrate:delete_orphan_applicants[false]"
  # Running with mock=true will output the number of records to be deleted without actually deleting any
  # (to allow for testing).

  task :delete_orphan_applicants, %i[mock] => :environment do |_task, args|
    mock = args[:mock].to_s.downcase.strip != "false"
    Rails.logger.info "delete_orphan_applicants: mock=#{mock}"
    orphan_applicants = Applicant.where.missing(:legal_aid_application)
    orphan_applicants_count = orphan_applicants.count
    Rails.logger.info "delete_orphan_applicants: Deleting #{orphan_applicants_count} orphan applicants"
    orphan_applicants.in_batches(&:destroy_all) unless mock
    Rails.logger.info "delete_orphan_applicants: #{orphan_applicants_count} orphan applicants deleted"
    Rails.logger.info "delete_orphan_applicants: #{orphan_applicants.count} orphan applicants remaining"
  end
end
