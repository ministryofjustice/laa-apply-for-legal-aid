namespace :migrate do
  desc "AP-4132 migrate provider_step from old vehicle pages to new vehicle_details page"

  task vehicle_pages: :environment do
    vehicle_pages = %w[vehicles_ages vehicles_estimated_values vehicles_remaining_payments vehicles_regular_uses]
    applications = LegalAidApplication.where(provider_step: vehicle_pages)
    Rails.logger.info "Migrating legal aid applications: setting provider_step: vehicle_details"
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Vehicles ages page count            : #{applications.where(provider_step: 'vehicles_ages').count}"
    Rails.logger.info "Vehicles estimated values page count: #{applications.where(provider_step: 'vehicles_estimated_values').count}"
    Rails.logger.info "Vehicles remaining payments count   : #{applications.where(provider_step: 'vehicles_remaining_payments').count}"
    Rails.logger.info "Vehicles regular use count          : #{applications.where(provider_step: 'vehicles_regular_uses').count}"
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Benchmark.benchmark do |bm|
      bm.report("Migrate:") do
        ActiveRecord::Base.transaction do
          applications.each do |app|
            app.provider_step = "vehicle_details"
            app.save!(touch: false) # this prevents the updated_at date being changed and delaying purging of stale records
          end
          raise StandardError, "Not all applications updated" if applications.where(provider_step: vehicle_pages).any?
        end
      end
    end
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Rails.logger.info "Applications updated    : #{LegalAidApplication.where(provider_step: 'vehicle_details').count}"
    Rails.logger.info "Applications not updated: #{applications.where(provider_step: vehicle_pages).count}"
    Rails.logger.info "----------------------------------------"
  end
end
