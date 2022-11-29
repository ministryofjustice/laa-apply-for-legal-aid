namespace :opponent do
  desc "Temporary task to move opponent full name into first/last name fields"
  task split_full_names: :environment do
    started = Time.zone.now
    Rails.logger.info "Running opponent:split_full_names"
    affected = ApplicationMeritsTask::Opponent.where.not(full_name: nil)
    Rails.logger.info "- #{affected.count} opponents found with split names"
    affected.each do |opponent|
      first_name, last_name = opponent.split_full_name
      opponent.update!(first_name:, last_name:, full_name: nil)
    end
    Rails.logger.info "- #{ApplicationMeritsTask::Opponent.where.not(full_name: nil).count} opponents left with split names"
    Rails.logger.info "Time taken: #{Time.zone.now - started}"
  end
end
