MigrationProgress = Struct.new(:opponents_total, :individuals_added, :individuals_already_exists) do
  def to_s
    to_h.map { |k, v| "#{k.to_s.split('_').map(&:capitalize).join(' ')}: #{v}" }.join("\n")
  end
end

namespace :migrate do
  desc "AP-4324: Migrate \"individual\" opponents to their own table"
  task opponents_to_individuals: :environment do
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Migrating opponents => individual_opponents"
    opponents = ApplicationMeritsTask::Opponent
    progress = MigrationProgress.new(opponents.count, 0, 0)

    Rails.logger.info "------------ setup complete ------------"
    Rails.logger.info "processing #{progress.opponents_total} opponents"
    Rails.logger.info "----------------------------------------"

    ActiveRecord::Base.transaction do
      opponents.in_batches do |batch|
        batch.each do |opponent|
          create_individual_opponent!(opponent, progress)
        end
      end
      raise ActiveRecord::TransactionRollbackError if count_mismatch?
    end
    Rails.logger.info "---------------- success ---------------"
  rescue ActiveRecord::TransactionRollbackError => e
    Rails.logger.info "---------------- failure ---------------"
    Rails.logger.info e.message
  ensure
    Rails.logger.info progress.to_s
    Rails.logger.info "----------------------------------------"
  end
end

def create_individual_opponent!(opponent, progress)
  if opponent.opposable
    progress.individuals_already_exists += 1
  else
    individual = ApplicationMeritsTask::Individual.create!(first_name: opponent.first_name, last_name: opponent.last_name)
    opponent.update!(opposable_id: individual.id, opposable_type: individual.class.to_s)
    progress.individuals_added += 1
  end
end

def count_mismatch?
  ApplicationMeritsTask::Individual.count != ApplicationMeritsTask::Opponent.count
end
