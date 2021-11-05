module HMRC
  FactoryBot.define do
    factory :hmrc_response, class: HMRC::Response do
      legal_aid_application
      use_case { 'one' }

      trait :use_case_one do
        use_case { 'one' }
      end

      trait :use_case_two do
        use_case { 'two' }
      end

      trait :in_progress do
        submission_id { SecureRandom.uuid }
        url { "#{Rails.configuration.x.hmrc_interface.host}api/v1/submission/result/#{submission_id}" }
      end
    end
  end
end
