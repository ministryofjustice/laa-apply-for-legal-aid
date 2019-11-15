FactoryBot.define do
  factory :ccms_submission_history, class: CCMS::SubmissionHistory do
    submission

    from_state { 'initialised' }
    to_state { 'case_ref_obtained' }
    success { Faker::Boolean.boolean }
    details { Faker::Lorem.word }
    request { Faker::Lorem.word }
    response { Faker::Lorem.word }
  end
end
