COMMON_ATTRIBUTES = %w[id first_name last_name ccms_opponent_id].freeze
DAS_ATTRIBUTES = %w[warning_letter_sent warning_letter_sent_details police_notified police_notified_details bail_conditions_set bail_conditions_set_details].freeze
OMC_ATTRIBUTES = %w[understands_terms_of_court_order understands_terms_of_court_order_details].freeze
SHARED_ATTRIBUTES = %w[legal_aid_application_id created_at updated_at].freeze

namespace :migrate do
  desc "AP-3873: Migrate the domestic_abuse_data from opponents into their own table"
  task opponents: :environment do
    ProgressStruct = Struct.new(:opponent_total, :das, :pmc)

    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Migrating opponents => domestic_abuse_summary and parties_mental_capacity"
    all_opponents = ApplicationMeritsTask::Opponent.all
    progress = ProgressStruct.new(all_opponents.count, 0, 0)
    @expected_domestic_abuse_summaries = all_opponents.where.not(warning_letter_sent: nil)
                                                      .or(all_opponents.where.not(warning_letter_sent_details: nil))
                                                      .or(all_opponents.where.not(police_notified: nil))
                                                      .or(all_opponents.where.not(police_notified_details: nil))
                                                      .or(all_opponents.where.not(bail_conditions_set: nil))
                                                      .or(all_opponents.where.not(bail_conditions_set_details: nil))
    @expected_parties_mental_capacities = all_opponents.where.not(understands_terms_of_court_order: nil)
                                                       .or(all_opponents.where.not(understands_terms_of_court_order_details: nil))
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Expecting DAS: #{@expected_domestic_abuse_summaries.count}, PMC: #{@expected_parties_mental_capacities.count}"
    Rails.logger.info "------------ setup complete ------------"
    Rails.logger.info "processing #{progress.opponent_total} opponents"
    Rails.logger.info "----------------------------------------"
    ActiveRecord::Base.transaction do
      @expected_domestic_abuse_summaries.in_batches do |batch|
        batch.each do |opponent|
          create_domestic_abuse_summary_from(opponent, progress)
        end
      end
      @expected_parties_mental_capacities.in_batches do |batch|
        batch.each do |opponent|
          create_parties_mental_capacity_from(opponent, progress)
        end
      end
      raise ActiveRecord::TransactionRollbackError if count_mismatch?
    end
    Rails.logger.info "---------------- success ---------------"
  rescue ActiveRecord::TransactionRollbackError
    Rails.logger.info "---------------- failure ---------------"
  ensure
    Rails.logger.info progress.to_s
    Rails.logger.info "----------------------------------------"
  end
end

def create_domestic_abuse_summary_from(opponent, progress)
  attributes = opponent.attributes.excluding(COMMON_ATTRIBUTES + OMC_ATTRIBUTES)
  ApplicationMeritsTask::DomesticAbuseSummary.create!(attributes)
  progress.das += 1
end

def create_parties_mental_capacity_from(opponent, progress)
  attributes = opponent.attributes.excluding(COMMON_ATTRIBUTES + DAS_ATTRIBUTES)
  ApplicationMeritsTask::PartiesMentalCapacity.create!(attributes)
  progress.pmc += 1
end

def count_mismatch?
  [
    @expected_domestic_abuse_summaries.count != ApplicationMeritsTask::DomesticAbuseSummary.count,
    @expected_parties_mental_capacities.count != ApplicationMeritsTask::PartiesMentalCapacity.count,
  ].any?
end
