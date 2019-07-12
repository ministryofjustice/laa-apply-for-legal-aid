FactoryBot.define do
  factory :office do
    ccms_id { rand(1..1000) }
    code { rand(1..1000).to_s }
    firm
  end
end
