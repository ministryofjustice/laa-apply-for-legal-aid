namespace :duplicate do
  desc "AP-6909: Duplicate completed_at to citizen_completed_at"

  task completed_at: :environment do
    applications_with_completed_at = LegalAidApplication.where.not(completed_at: nil)
    Rails.logger.info "Duplicating completed_at => citizen_completed_at"
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "LegalAidApplication with completed_at: #{applications_with_completed_at.count}"
    Rails.logger.info "LegalAidApplication with citizen_completed_at: #{applications_with_completed_at.where.not(citizen_completed_at: nil).count}"
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    ActiveRecord::Base.transaction do
      applications_with_completed_at.each do |app|
        app.update!(citizen_completed_at: app.completed_at)
      end
      raise StandardError, "Not all LegalAidApplications updated" if applications_with_completed_at.where(citizen_completed_at: nil).any?
    end
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Rails.logger.info "LegalAidApplications with citizen_completed_at: #{applications_with_completed_at.where.not(citizen_completed_at: nil).count}"
    Rails.logger.info "LegalAidApplications without citizen_completed_at: #{applications_with_completed_at.where(citizen_completed_at: nil).count}"
    Rails.logger.info "----------------------------------------"
  end
end
