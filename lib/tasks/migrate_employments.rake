namespace :migrate do
  desc "AP-3805: Migrate the ownership of employments to applicant"
  # This will allow future employments to be assigned to partner
  task employments: :environment do
    records = Employment.all
    Rails.logger.info "Migrating employments => Applicant"
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "HMRCResponse.count: #{records.count}"
    Rails.logger.info "HMRCResponse with owner: #{records.where.not(owner_id: nil).count}"
    Rails.logger.info "HMRCResponse without owner: #{records.where(owner_id: nil).count}"
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Benchmark.benchmark do |bm|
      bm.report("Migrate:") do
        ActiveRecord::Base.transaction do
          records.where(owner_id: nil).find_each do |record|
            applicant = record.legal_aid_application.applicant
            record.update!(
              owner_id: applicant.id,
              owner_type: applicant.class,
            )
          end
        end
      end
      raise StandardError, "Not all employments updated" if records.where(owner_id: nil).any?
    end
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Rails.logger.info "Employments with owner: #{records.where.not(owner_id: nil).count}"
    Rails.logger.info "Employments without owner: #{records.where(owner_id: nil).count}"
    Rails.logger.info "----------------------------------------"
  end
end
