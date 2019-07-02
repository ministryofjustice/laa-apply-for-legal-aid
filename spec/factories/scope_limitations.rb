FactoryBot.define do
  factory :scope_limitation do
    sequence(:code) { |n| format('AA%03d', n) }
    meaning { 'Meaning' }
    description { 'Description' }
    substantive { true }
    delegated_functions { false }
  end

  trait :with_real_data do
    code { 'AA009' }
    meaning { 'Warrant of arrest FLA' }
    description { 'As to an order under Part IV Family Law Act 1996 limited to an application for the issue of a warrant of arrest.' }
    substantive { true }
    delegated_functions { true }
  end
end
