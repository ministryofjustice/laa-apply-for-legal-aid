MigrationProgress = Struct.new(:opponents_total, :individuals_added, :individuals_already_exists) do
  def to_s
    to_h.map { |k, v| "#{k.to_s.split('_').map(&:capitalize).join(' ')}: #{v}" }.join("\n")
  end
end

namespace :migrate do
  desc "AP-4284: Migrate \"individual\" opponents to their own table"
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

  desc "AP-4284: Stats for \"individual\" opponents"
  task opponents_to_individuals_stats: :environment do
    ind_count = ApplicationMeritsTask::Individual.count
    ind_orphan_count = ApplicationMeritsTask::Individual.where.missing(:opponent).count
    opp_count = ApplicationMeritsTask::Opponent.count
    opp_individuals_count = ApplicationMeritsTask::Opponent.where(opposable_type: "ApplicationMeritsTask::Individual").count
    opp_individualless_count = ActiveRecord::Base.connection.execute(individualless_opponents_sql).getvalue(0, 0)

    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Individuals: #{ind_count}"
    Rails.logger.info "Orphan Individuals: #{ind_orphan_count}"
    Rails.logger.info "Opponents: #{opp_count}"
    Rails.logger.info "Opponent Individuals: #{opp_individuals_count}"
    Rails.logger.info "Opponents without individuals: #{opp_individualless_count}"
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

def individualless_opponents_sql
  <<~SQL.squish
    SELECT count(opponents.id)
    FROM opponents
    WHERE (
      opponents.opposable_type = 'ApplicationMeritsTask::Individual'
      OR opponents.opposable_type IS NULL
    )
    AND NOT EXISTS (
        SELECT 1
        FROM individuals
        WHERE individuals.id = opponents.opposable_id
    )
  SQL
end

def count_mismatch?
  ApplicationMeritsTask::Individual.count != ApplicationMeritsTask::Opponent.count
end
