namespace :stats do
  desc "Stats for \"individual\" and \"organisation\" opponents"
  task opponents: :environment do
    ind_count = ApplicationMeritsTask::Individual.count
    org_count = ApplicationMeritsTask::Organisation.count
    ind_orphan_count = ApplicationMeritsTask::Individual.where.missing(:opponent).count
    org_orphan_count = ApplicationMeritsTask::Organisation.where.missing(:opponent).count
    opp_count = ApplicationMeritsTask::Opponent.count
    opp_individuals_count = ApplicationMeritsTask::Opponent.where(opposable_type: "ApplicationMeritsTask::Individual").count
    opp_individualless_count = ActiveRecord::Base.connection.execute(individualless_opponents_sql).getvalue(0, 0)
    opp_organisations_count = ApplicationMeritsTask::Opponent.where(opposable_type: "ApplicationMeritsTask::Organisation").count
    opp_organisationless_count = ActiveRecord::Base.connection.execute(organisationless_opponents_sql).getvalue(0, 0)
    opp_unopposable_count = ApplicationMeritsTask::Opponent.where(opposable_type: nil).count

    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Total Individuals: #{ind_count}"
    Rails.logger.info "Total Organisations: #{org_count}"
    Rails.logger.info "Total Opponents: #{opp_count}"
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Orphan Individuals: #{ind_orphan_count}"
    Rails.logger.info "Opponent Individuals: #{opp_individuals_count}"
    Rails.logger.info "Opponent Individuals without individuals: #{opp_individualless_count}"
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Orphan Organisations: #{org_orphan_count}"
    Rails.logger.info "Opponent Organisations: #{opp_organisations_count}"
    Rails.logger.info "Opponent Organsiations without Organisations: #{opp_organisationless_count}"
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Opponents without opposable relation: #{opp_unopposable_count}"
    Rails.logger.info "----------------------------------------"
  end
end

def individualless_opponents_sql
  <<~SQL.squish
    SELECT count(opponents.id)
    FROM opponents
    WHERE opponents.opposable_type = 'ApplicationMeritsTask::Individual'
    AND NOT EXISTS (
        SELECT 1
        FROM individuals
        WHERE individuals.id = opponents.opposable_id
    )
  SQL
end

def organisationless_opponents_sql
  <<~SQL.squish
    SELECT count(opponents.id)
    FROM opponents
    WHERE opponents.opposable_type = 'ApplicationMeritsTask::Organisation'
    AND NOT EXISTS (
        SELECT 1
        FROM organisations
        WHERE organisations.id = opponents.opposable_id
    )
  SQL
end
