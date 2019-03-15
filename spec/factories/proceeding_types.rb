FactoryBot.define do
  factory :proceeding_type do
    sequence(:code) { |n| format('PR%04d', n) }
    ccms_code { 'PBM23' }
    meaning { 'Meaning' }
    description { 'Description' }
    ccms_category_law { 'Category law' }
    ccms_category_law_code { 'Category law code' }
    ccms_matter { 'Matter' }
    ccms_matter_code { 'Matter code' }

    trait :domestic_abuse do
      ccms_matter_code { 'MINJN' }
    end
  end
end
