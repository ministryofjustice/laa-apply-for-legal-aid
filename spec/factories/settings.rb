FactoryBot.define do
  factory :setting do
    mock_true_layer_data { false }
    allow_non_passported_route { false }
    use_mock_provider_details { false }

    trait :use_mock_provider_details do
      use_mock_provider_details { true }
    end

    initialize_with { Setting.setting }
  end
end
