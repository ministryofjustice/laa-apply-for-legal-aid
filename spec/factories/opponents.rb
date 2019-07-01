FactoryBot.define do
  factory :opponent do
    other_party_id { 'OPPONENT_00000001' }
    title { 'MR.' }
    first_name { 'Dummy' }
    surname { 'Opponent' }
    date_of_birth { Date.new(2015, 1, 1) }
    relationship_to_case { 'OPP' }
    relationship_to_client { 'EX_SPOUSE' }
    opponent_type { 'PERSON' }
    opp_relationship_to_case { 'Opponent' }
    opp_relationship_to_client { 'Ex Husband/ Wife' }
    child { false }

    trait :child do
      other_party_id { 'OPPONENT_11594798' }
      title { 'MASTER' }
      first_name { 'BoBo' }
      surname { 'Fabby' }
      date_of_birth { Date.new(2015, 1, 1) }
      relationship_to_case { 'CHILD' }
      relationship_to_client { 'CHILD' }
      opponent_type { 'PERSON' }
      opp_relationship_to_case { 'Child' }
      opp_relationship_to_client { 'Child' }
      child { true }
    end

    trait :ex_spouse do
      other_party_id { 'OPPONENT_11594796' }
      title { 'MRS.' }
      first_name { 'Fabby' }
      surname { 'Fabby' }
      date_of_birth { Date.new(1980, 1, 1) }
      relationship_to_case { 'OPP' }
      relationship_to_client { 'EX_SPOUSE' }
      opponent_type { 'PERSON' }
      opp_relationship_to_case { 'Opponent' }
      opp_relationship_to_client { 'Ex Husband/ Wife' }
      child { false }
    end
  end
end
