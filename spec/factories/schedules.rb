FactoryBot.define do
  factory :schedule do
    office_id { Faker::Number.unique.number(digits: 10).to_s }
    area_of_law { "LEGAL HELP" }
    category_of_law { "MAT" }
    authorisation_status { "APPROVED" }
    status { "Open" }
    cancelled { false }
    office
  end

  trait :valid do
    start_date { Date.current - 10.weeks }
    end_date { Date.current + 10.weeks }
    license_indicator { 1 }
    devolved_power_status { "Yes - Excluding JR Proceedings" }
  end
end
