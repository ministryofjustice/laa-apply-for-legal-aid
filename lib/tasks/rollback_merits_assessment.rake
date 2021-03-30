task rollback: :environment do
  LegalAidApplication.where(provider_step: 'start_chances_of_successes').each do |app|
    app.provider_step = 'start_merits_assessments'
    app.save
  end
end
