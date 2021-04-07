module ApplicationMeritsTask
  FactoryBot.define do
    factory :involved_child, class: ApplicationMeritsTask::InvolvedChild do
      legal_aid_application
      full_name { Faker::Name.name }
      date_of_birth { Faker::Date.between(from: Date.new(2000, 1, 1), to: Date.current) }
    end
  end
end
