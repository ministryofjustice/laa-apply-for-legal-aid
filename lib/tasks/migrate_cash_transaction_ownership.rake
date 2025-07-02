namespace :migrate do
  desc "AP-4285: Migrate the ownership of cash transactions to applicant"
  # This will allow future employments to be assigned to partner
  task cash_transaction_ownership: :environment do
    records = CashTransaction.all
    Rails.logger.info "Migrating cash_transaction => Applicant"
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "cash_transactions.count: #{records.count}"
    Rails.logger.info "cash_transactions with owner: #{records.where.not(owner_id: nil).count}"
    Rails.logger.info "cash_transactions without owner: #{records.where(owner_id: nil).count}"
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
          raise StandardError, "Not all cash_transactions updated" if records.where(owner_id: nil).any?
        end
      end
    end
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Rails.logger.info "cash_transactions with owner: #{records.where.not(owner_id: nil).count}"
    Rails.logger.info "cash_transactions without owner: #{records.where(owner_id: nil).count}"
    Rails.logger.info "----------------------------------------"
  end
end
