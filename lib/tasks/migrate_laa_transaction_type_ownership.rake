namespace :migrate do
  desc "AP-4285: Migrate the ownership of legal_aid_application_transaction_types to applicant"
  # This will allow future legal_aid_application_transaction_types to be assigned to partner
  task legal_aid_application_transaction_types_ownership: :environment do
    records = LegalAidApplicationTransactionType.all
    Rails.logger.info "Migrating legal_aid_application_transaction_types => Applicant"
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "legal_aid_application_transaction_types.count: #{records.count}"
    Rails.logger.info "legal_aid_application_transaction_types with owner: #{records.where.not(owner_id: nil).count}"
    Rails.logger.info "legal_aid_application_transaction_types without owner: #{records.where(owner_id: nil).count}"
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
          raise StandardError, "Not all legal_aid_application_transaction_types updated" if records.where(owner_id: nil).any?
        end
      end
    end
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Rails.logger.info "legal_aid_application_transaction_types with owner: #{records.where.not(owner_id: nil).count}"
    Rails.logger.info "legal_aid_application_transaction_types without owner: #{records.where(owner_id: nil).count}"
    Rails.logger.info "----------------------------------------"
  end
end
