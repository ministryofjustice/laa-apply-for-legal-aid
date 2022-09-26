namespace :migrate do
  desc "AP-3495: Migrate the scope_limitation data from proceedings into their own table"
  # This was done as a rake task as it was taking ~50 seconds to run when deploying to K8s
  # and exceeding the liveness checks
  task scope_limitations: :environment do
    Rails.logger.info "Migrating Proceeding => ScopeLimitations"
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Proceeding.count: #{Proceeding.count}"
    Rails.logger.info "ScopeLimitation.count: #{ScopeLimitation.count}"
    Benchmark.benchmark do |bm|
      bm.report("Migrate:") do
        ActiveRecord::Base.transaction do
          Proceeding.all.each do |proceeding|
            if proceeding.substantive_scope_limitation_code.present?
              ScopeLimitation.find_or_create_by!(proceeding:,
                                                 scope_type: :substantive,
                                                 code: proceeding.substantive_scope_limitation_code,
                                                 meaning: proceeding.substantive_scope_limitation_meaning,
                                                 description: proceeding.substantive_scope_limitation_description)
            end
            if proceeding.used_delegated_functions? && proceeding.delegated_functions_scope_limitation_code.present?
              ScopeLimitation.find_or_create_by!(proceeding:,
                                                 scope_type: :emergency,
                                                 code: proceeding.delegated_functions_scope_limitation_code,
                                                 meaning: proceeding.delegated_functions_scope_limitation_meaning,
                                                 description: proceeding.delegated_functions_scope_limitation_description)
            end
            proceeding.update!(substantive_scope_limitation_code: nil,
                               substantive_scope_limitation_meaning: nil,
                               substantive_scope_limitation_description: nil,
                               delegated_functions_scope_limitation_code: nil,
                               delegated_functions_scope_limitation_meaning: nil,
                               delegated_functions_scope_limitation_description: nil)
          end
        end
      end
    end
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Rails.logger.info "Proceeding.count: #{Proceeding.count}"
    Rails.logger.info "ScopeLimitation.count: #{ScopeLimitation.count}"
    Rails.logger.info "Expect ScopeLimitation.count to eq: #{Proceeding.where(used_delegated_functions: true).count + Proceeding.count}"
    Rails.logger.info "========================================"
  end
end
