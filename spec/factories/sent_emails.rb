FactoryBot.define do
  factory :sent_email do
    mailer { 'MyTestMailer' }
    mail_method { 'notify' }
    addressee { Faker::Internet.email }
    govuk_message_id { SecureRandom.uuid }
    mailer_args { ['a', addressee, 'xxx'].to_json }
    sent_at { 1.hour.ago }
    status { 'created' }

    trait :created do
      status { 'created' }
    end

    trait :delivered do
      status { 'delivered' }
    end

    trait :pending do
      status { 'pending' }
    end
  end
end
