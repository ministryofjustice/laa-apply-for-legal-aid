FactoryBot.define do
  factory :final_hearing do
    proceeding

    work_type { :substantive }
    listed { true }
    date { Time.zone.today.at_beginning_of_month.next_month }
  end
end
