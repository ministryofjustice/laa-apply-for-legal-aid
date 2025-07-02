namespace :migrate do
  desc "AP-3805: Migrate the ownership of HMRC responses to applicant"
  # This will allow future HMRC responses to be assigned to partner
  task hmrc_responses: :environment do
    responses = HMRC::Response.all
    Rails.logger.info "Migrating HMRC responses => Applicant"
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "HMRCResponse.count: #{responses.count}"
    Rails.logger.info "HMRCResponse with owner: #{responses.where.not(owner_id: nil).count}"
    Rails.logger.info "HMRCResponse without owner: #{responses.where(owner_id: nil).count}"
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Benchmark.benchmark do |bm|
      bm.report("Migrate:") do
        ActiveRecord::Base.transaction do
          responses.where(owner_id: nil).find_each do |response|
            applicant = response.legal_aid_application.applicant
            response.update!(
              owner_id: applicant.id,
              owner_type: applicant.class,
            )
          end
        end
      end
      raise StandardError, "Not all responses updated" if responses.where(owner_id: nil).any?
    end
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Rails.logger.info "HMRCResponse with owner: #{responses.where.not(owner_id: nil).count}"
    Rails.logger.info "HMRCResponse without owner: #{responses.where(owner_id: nil).count}"
    Rails.logger.info "----------------------------------------"
  end
end
