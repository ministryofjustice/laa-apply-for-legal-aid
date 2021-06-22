namespace :clean_whitespaces do
  desc 'Clean/Squish whitespaces from Applicants, Dependants and Opponents'
  task clean: :environment do
    Applicant.find_each do |applicant|
      applicant.first_name = applicant.first_name.squish
      applicant.last_name = applicant.last_name.squish
      applicant.save!
    end
    Dependant.find_each do |dependant|
      dependant.name = dependant.first_name.squish
      dependant.save!
    end
    ApplicationMeritsTask::Opponent.find_each do |opponent|
      opponent.full_name = opponent.full_name.squish
      opponent.save!
    end
  end
end
