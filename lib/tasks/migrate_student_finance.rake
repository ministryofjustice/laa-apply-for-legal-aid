namespace :migrate do
  desc "AP-4105: Migrate the student finance information to applicant"
  # This will allow future student finance responses to be assigned to partner
  task student_finance_responses: :environment do
    Rails.logger.info "Migrating student finance responses => Applicant"
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "LegalAidApplication.count: #{LegalAidApplication.count}"
    Rails.logger.info "LegalAidApplication with student finance on application model: #{LegalAidApplication.where(student_finance: true).count}"
    Rails.logger.info "LegalAidApplication with student finance on applicant model: #{Applicant.where(student_finance: true).count}"
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Benchmark.benchmark do |bm|
      ActiveRecord::Base.transaction do
        bm.report("Migrate:") do
          LegalAidApplication.where(student_finance: true).each do |laa|
            laa.applicant.update!(student_finance: true)
            laa.applicant.update!(student_finance_amount: laa.irregular_incomes.first.amount) if laa.irregular_incomes.exists?

            laa.update!(student_finance: nil)
            laa.irregular_incomes.first.destroy!
          end
        end
        raise StandardError, "Not all responses updated" if LegalAidApplication.where(student_finance: true).count.positive?
      end
    end
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Rails.logger.info "LegalAidApplication with student finance on application model: #{LegalAidApplication.where(student_finance: true).count}"
    Rails.logger.info "LegalAidApplication with student finance on applicant model: #{Applicant.where(student_finance: true).count}"
    Rails.logger.info "----------------------------------------"
  end
end
