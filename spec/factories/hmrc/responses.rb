require Rails.root.join("spec/factory_helpers/hmrc_response/use_case_one.rb")

module HMRC
  FactoryBot.define do
    factory :hmrc_response, class: "HMRC::Response" do
      legal_aid_application
      submission_id { SecureRandom.uuid }
      use_case { "one" }

      trait :with_legal_aid_applicant do
        legal_aid_application { build(:legal_aid_application, :with_applicant) }
      end

      trait :use_case_one do
        use_case { "one" }
        response { ::FactoryHelpers::HMRCResponse::UseCaseOne.new(submission_id).response }
      end

      trait :use_case_two do
        use_case { "two" }
      end

      trait :nil_response do
        response { nil }
      end

      trait :processing do
        response { ::FactoryHelpers::HMRCResponse::UseCaseOne.new(submission_id, status: "processing").response }
      end

      trait :in_progress do
        submission_id { SecureRandom.uuid }
        url { "#{Rails.configuration.x.hmrc_interface.host}api/v1/submission/result/#{submission_id}" }
      end

      trait :example1_usecase1 do
        use_case { "one" }
        response { ::FactoryHelpers::HMRCResponse::UseCaseOne.new(submission_id, named_data: :example1_usecase1).response }
      end

      trait :multiple_employments_usecase1 do
        use_case { "one" }
        response { ::FactoryHelpers::HMRCResponse::UseCaseOne.new(submission_id, named_data: :multiple_employments_usecase1).response }
      end

      trait :all_remarks_usecase1 do
        use_case { "one" }
        response { ::FactoryHelpers::HMRCResponse::UseCaseOne.new(submission_id, named_data: :all_remarks_usecase1).response }
      end
    end
  end
end
