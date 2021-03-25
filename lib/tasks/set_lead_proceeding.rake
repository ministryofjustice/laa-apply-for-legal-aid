namespace :update_lead_proceeding do
  desc 'Sets the lead_proceeding value to TRUE for all existing cases'

  task set_value_to_true: :environment do
    ApplicationProceedingType.all.each do |t|
      t.update(lead_proceeding: true)
    end
  end
end
