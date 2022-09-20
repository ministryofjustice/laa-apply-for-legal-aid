# frozen_string_literal: true

class ExtractScopeLimitations < ActiveRecord::Migration[7.0]
  require "benchmark"

  def up
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
            next unless proceeding.used_delegated_functions? && proceeding.delegated_functions_scope_limitation_code.present?

            ScopeLimitation.find_or_create_by!(proceeding:,
                                               scope_type: :emergency,
                                               code: proceeding.delegated_functions_scope_limitation_code,
                                               meaning: proceeding.delegated_functions_scope_limitation_meaning,
                                               description: proceeding.delegated_functions_scope_limitation_description)
          end
        end
      end
    end
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Proceeding.count: #{Proceeding.count}"
    Rails.logger.info "ScopeLimitation.count: #{ScopeLimitation.count}"
    Rails.logger.info "Expect ScopeLimitation.count to eq: #{Proceeding.where(used_delegated_functions: true).count + Proceeding.count}"
    Rails.logger.info "========================================"
  end

  def down
    Rails.logger.info "Migrating ScopeLimitations => Proceeding"
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Proceeding.count: #{Proceeding.count}"
    Rails.logger.info "ScopeLimitation.count: #{ScopeLimitation.count}"
    Benchmark.bm do |bm|
      ActiveRecord::Base.transaction do
        bm.report("Migrate:") do
          ScopeLimitation.all.each do |scope_limitation|
            proceeding = scope_limitation.proceeding
            if scope_limitation.emergency?
              proceeding.update!(delegated_functions_scope_limitation_code: scope_limitation.code,
                                 delegated_functions_scope_limitation_meaning: scope_limitation.meaning,
                                 delegated_functions_scope_limitation_description: scope_limitation.description)
            else
              proceeding.update!(substantive_scope_limitation_code: scope_limitation.code,
                                 substantive_scope_limitation_meaning: scope_limitation.meaning,
                                 substantive_scope_limitation_description: scope_limitation.description)
            end
          end
        end
        bm.report("Destroy:") do
          ScopeLimitation.destroy_all
        end
      end
      Rails.logger.info "----------------------------------------"
      Rails.logger.info "Proceeding.count: #{Proceeding.count}"
      Rails.logger.info "ScopeLimitation.count: #{ScopeLimitation.count}"
      Rails.logger.info "Expect ScopeLimitation.count to be 0"
      Rails.logger.info "========================================"
    end
  end
end
