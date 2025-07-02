namespace :migrate do
  desc "AP-4132 migrate provider_step from old property pages to new property_details page"

  task property_pages: :environment do
    property_pages = %w[property_values outstanding_mortgages shared_ownerships percentage_homes]
    applications = LegalAidApplication.where(provider_step: property_pages)
    Rails.logger.info "Migrating legal aid applications: setting provider_step: property_details"
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Property values page count: #{applications.where(provider_step: 'property_values').count}"
    Rails.logger.info "Outstanding mortgages page count: #{applications.where(provider_step: 'outstanding_mortgages').count}"
    Rails.logger.info "Shared ownerships page count: #{applications.where(provider_step: 'shared_ownerships').count}"
    Rails.logger.info "Percentage homes page count: #{applications.where(provider_step: 'percentage_homes').count}"
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Benchmark.benchmark do |bm|
      bm.report("Migrate:") do
        ActiveRecord::Base.transaction do
          applications.each do |app|
            app.update!(provider_step: "property_details")
          end
        end
      end
      raise StandardError, "Not all applications updated" if applications.where(provider_step: property_pages).any?
    end
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Rails.logger.info "Applications updated: #{LegalAidApplication.where(provider_step: 'property_details').count}"
    Rails.logger.info "Applications not updated: #{applications.where(provider_step: property_pages).count}"
    Rails.logger.info "----------------------------------------"
  end
end
