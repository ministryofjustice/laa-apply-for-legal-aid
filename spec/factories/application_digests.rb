FactoryBot.define do
  factory :application_digest do
    legal_aid_application_id { SecureRandom.uuid }
    firm_name { 'Kuznetsov LLC' }
    provider_username { 'user_1' }
    date_started { Time.zone.yesterday }
    date_submitted { Time.zone.today }
    days_to_submission { 1 }
    use_ccms { false }
    matter_types { 'Domestic Abuse' }
    proceedings { 'DA001;DA004' }
    passported { true }
    df_used { true }
    earliest_df_date { Time.zone.yesterday }
    df_reported_date { Time.zone.today }
    working_days_to_report_df { 1 }
  end
end
