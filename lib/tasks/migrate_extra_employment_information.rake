namespace :migrate do
  desc "AP-4326 migrate extra_employment_information and employment_information_details from LegalAidApplication to Applicant"

  task extra_employment_information: :environment do
    applications = LegalAidApplication.all
    Rails.logger.info "Migrating legal aid applications: retrieving all applications"
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Counting applications with extra employment information"
    apps_count = LegalAidApplication.where(extra_employment_information: true).count
    Rails.logger.info "#{apps_count} applications with extra employment information"
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Benchmark.benchmark do |bm|
      bm.report("Migrate:") do
        ActiveRecord::Base.transaction do
          applications.each do |legal_aid_application|
            applicant = legal_aid_application.applicant
            extra_employment_information = legal_aid_application.extra_employment_information?
            applicant.update!(extra_employment_information:)
            if extra_employment_information
              extra_employment_information_details = legal_aid_application.extra_employment_information_details
              applicant.update!(extra_employment_information_details:)
            end
          end
        end
      end
      raise StandardError, "Not all applications updated" if Applicant.where(extra_employment_information: true).count != apps_count
    end
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    updated_applicants_count = Applicant.where(extra_employment_information: true).count
    Rails.logger.info "Applicants updated: #{updated_applicants_count}"
    Rails.logger.info "Applications not updated: #{apps_count - updated_applicants_count}"
    Rails.logger.info "----------------------------------------"
  end
end
