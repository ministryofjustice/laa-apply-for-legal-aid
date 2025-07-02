namespace :migrate do
  desc "AP-4138: Add the owner of vehicles to exiting applications"

  task vehicle_ownership: :environment do
    records = Vehicle.all
    Rails.logger.info "Add vehicle ownership => Applicant"
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "vehicle.count: #{records.count}"
    Rails.logger.info "vehicle with owner: #{records.where.not(owner: nil).count}"
    Rails.logger.info "vehicle without owner: #{records.where(owner: nil).count}"
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Benchmark.benchmark do |bm|
      bm.report("Migrate:") do
        ActiveRecord::Base.transaction do
          records.where(owner: nil).find_each do |record|
            record.update!(owner: "client")
          end
          raise StandardError, "Not all vehicles updated" if records.where(owner: nil).any?
        end
      end
    end
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Rails.logger.info "vehicle with owner: #{records.where.not(owner: nil).count}"
    Rails.logger.info "vehicle without owner: #{records.where(owner: nil).count}"
    Rails.logger.info "----------------------------------------"
  end
end
