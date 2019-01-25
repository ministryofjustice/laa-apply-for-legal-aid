FactoryBot.define do
  factory :feedback do
    done_all_needed { false }
    satisfaction { 1 }
    improvment_suggestion { 'MyText' }
  end
end
