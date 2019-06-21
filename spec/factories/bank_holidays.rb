FactoryBot.define do
  factory :bank_holiday do
    dates { 5.times.to_a.map { |n| n.weeks.from_now.to_date.to_s } }
  end
end
