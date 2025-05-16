namespace :migrate do
  desc "AP-5970 move in progress applications to location of new nino page"

  task move_to_nino_page: :environment do
    addresses_pages = %w[
      correspondence_address_choices
      correspondence_address_lookups
      correspondence_address_selections
      correspondence_address_manuals
      correspondence_address_care_ofs
      home_address_statuses
      home_address_lookups
      home_address_selections
      home_address_manuals
      non_uk_home_addresses
    ]

    linking_and_copying_pages = %w[
      link_application_make_links
      link_application_find_link_applications
      link_application_confirm_links
      link_application_copies
    ]

    proceedings = %w[
      proceedings_types
      proceedings_sca_proceeding_issue_statuses
      proceedings_sca_supervision_orders
      proceedings_sca_child_subjects
      proceedings_sca_heard_togethers
      proceedings_sca_heard_as_alternatives
      proceedings_sca_interrupts
      change_of_names
      change_of_names_interrupts
      has_other_proceedings
      limitations
      client_involvement_type
      delegated_functions
      confirm_delegated_functions_date
      emergency_defaults
      substantive_defaults
      emergency_level_of_service
      substantive_level_of_service
      final_hearings
      emergency_scope_limitations
      substantive_scope_limitations
      related_orders
    ]

    pages_to_move = %w[previous_references] + addresses_pages + linking_and_copying_pages + proceedings

    applications = LegalAidApplication.where(provider_step: pages_to_move)
    Rails.logger.info "Migrating legal aid applications: setting provider_step: has_national_insurance_numbers"
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Number of applications that need to be moved: #{applications.where(provider_step: pages_to_move).count}"
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Benchmark.benchmark do |bm|
      bm.report("Migrate:") do
        ActiveRecord::Base.transaction do
          applications.each do |app|
            app.provider_step = "has_national_insurance_numbers"
            app.save!(touch: false) # this prevents the updated_at date being changed and delaying purging of stale records
          end
          raise StandardError, "Not all applications updated" if applications.where(provider_step: pages_to_move).count.positive?
        end
      end
    end
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Rails.logger.info "Applications updated    : #{LegalAidApplication.where(provider_step: 'has_national_insurance_numbers').count}"
    Rails.logger.info "Applications not updated: #{applications.where(provider_step: pages_to_move).count}"
    Rails.logger.info "----------------------------------------"
  end
end
