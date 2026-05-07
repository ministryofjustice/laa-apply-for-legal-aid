namespace :migrate do
  desc "AP-6896 migrate full_employment_details from LegalAidApplication to Applicant"

  task full_employment_details: :environment do
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Counting applications with full_employment_details"
    applications = LegalAidApplication.where.not(full_employment_details: nil)
    Rails.logger.info "#{applications.count} applications with full_employment_details"
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    ActiveRecord::Base.transaction do
      applications.each do |legal_aid_application|
        applicant = legal_aid_application.applicant
        applicant.update!(full_employment_details: legal_aid_application.full_employment_details)
      end
      raise StandardError, "Not all applications updated" if Applicant.where.not(full_employment_details: nil).count != applications.count
    end
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    updated_applicants_count = Applicant.where.not(full_employment_details: nil).count
    Rails.logger.info "Applicants updated: #{updated_applicants_count}"
    Rails.logger.info "Applications not updated: #{applications.count - updated_applicants_count}"
    Rails.logger.info "----------------------------------------"
  end
end
