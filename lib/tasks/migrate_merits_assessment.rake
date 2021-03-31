namespace :merits_assessment_flow_steps do
  desc 'Rename start_merits_assessments flow step to start_chances_of_successes'
  task migrate: :environment do
    LegalAidApplication.where(provider_step: 'start_merits_assessments').each do |app|
      app.provider_step = 'start_chances_of_successes'
      app.save
    end
  end

  task rollback: :environment do
    LegalAidApplication.where(provider_step: 'start_chances_of_successes').each do |app|
      app.provider_step = 'start_merits_assessments'
      app.save
    end
  end
end
