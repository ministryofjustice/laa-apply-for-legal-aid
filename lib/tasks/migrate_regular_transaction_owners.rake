namespace :migrate do
  desc "AP-3909: Migrate the ownership of regular transactions to the applicants"
  # This will allow future transactions to be assigned to partner/dependant/alien/etc
  task regular_transaction_owners: :environment do
    transactions = RegularTransaction.all
    Rails.logger.info "Migrating regular transactions => Applicant"
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "RegularTransaction.count: #{transactions.count}"
    Rails.logger.info "RegularTransaction with owner: #{transactions.where.not(owner_id: nil).count}"
    Rails.logger.info "RegularTransaction without owner: #{transactions.where(owner_id: nil).count}"
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Benchmark.benchmark do |bm|
      bm.report("Migrate:") do
        ActiveRecord::Base.transaction do
          transactions.where(owner_id: nil).each do |transaction|
            applicant = transaction.legal_aid_application.applicant
            transaction.update!(
              owner_id: applicant.id,
              owner_type: applicant.class,
            )
          end
        end
      end
      raise StandardError, "Not all transactions updated" if transactions.where(owner_id: nil).count.positive?
    end
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Rails.logger.info "RegularTransaction with owner: #{transactions.where.not(owner_id: nil).count}"
    Rails.logger.info "RegularTransaction without owner: #{transactions.where(owner_id: nil).count}"
    Rails.logger.info "----------------------------------------"
  end
end
