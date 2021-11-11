FactoryBot.define do
  factory :application_digest do
    legal_aid_application_id { SecureRandom.uuid }
    firm_name { Faker::Company.name }
    provider_username { Faker::Internet.unique.username }
    date_started { Faker::Date.backward(days: 90) }
    date_submitted { date_started + [0, 0, 1, 2, 3, 10, 15, 20].sample.days }
    days_to_submission { date_submitted - date_started + 1 }
    use_ccms { [false, true, true, true].sample }
    matter_types { ['Domestic Abuse', 'Domestic Abuse;Section 8 orders'].sample }
    proceedings { matter_types == 'Domestic Abuse' ? 'DA004;DA005' : 'DA001;SE013;SE014' }
    passported { [true, false].sample }
    df_used { [true, false].sample }
    earliest_df_date { df_used ? Faker::Date.backward(days: rand(0..5)) : nil }
    df_reported_date { earliest_df_date.nil? ? nil : earliest_df_date + rand(0..5).days }
    working_days_to_report_df { earliest_df_date.nil? ? nil : df_reported_date - earliest_df_date }
    working_days_to_submit_df { earliest_df_date.nil? ? nil : date_submitted - earliest_df_date }
  end
end


# e8751ef2-5214-4997-929a-c59c0b9cf432,   id
# c7023c4d-a595-43e0-8088-6177657d360e,   laa id
# Wyman-Bergnaum,                         firm name
# art_gottlieb,                           username
# 2021-08-13,                             started
# 2021-08-13,                             submitted
# 1,                                      days to submission
# t,                                      use_ccms
# Domestic Abuse;Section 8 orders,        matter types
# DA001;SE013;SE014,                      proceedings
# t,                                      passported
# f,                                      df used
# null,                                   earliest df date
# null,                                   df_reported_date
# null,                                   working days to report
# null,                                   working days to submit
# null,                                   dreated at
# null                                    updated at
