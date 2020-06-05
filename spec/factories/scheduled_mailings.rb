FactoryBot.define do
  factory :scheduled_mailing do
    legal_aid_application

    mailer_klass { 'SubmitApplicationReminderMailer' }
    mailer_method { 'notify_provider' }
    arguments { [legal_aid_application.id, 'Bob Marley', 'bob@wailing.jm'] }
    scheduled_at { Faker::Time.between(from: 1.minute.from_now, to: 2.months.from_now) }

    trait :due do
      scheduled_at { Faker::Time.between(from: 2.months.ago, to: 1.minute.ago) }
    end

    trait :sent do
      scheduled_at { Faker::Time.between(from: 2.months.ago, to: 1.minute.ago) }
      sent_at { scheduled_at + 15.seconds }
    end

    trait :invalid do
      scheduled_at { Faker::Time.between(from: 2.months.ago, to: 1.minute.ago) }
      sent_at { scheduled_at + 15.seconds }
      arguments { ['11111', 'Bob Marley', 'bob@wailing.jm'] }
    end

    trait :provider_financial_reminder do
      mailer_klass { 'SubmitProviderFinancialReminderMailer' }
      mailer_method { 'notify_provider' }
      scheduled_at { Faker::Time.between(from: 2.months.ago, to: 1.minute.ago) }
    end

    trait :cancelled do
      scheduled_at { Faker::Time.between(from: 2.months.ago, to: 1.minute.ago) }
      cancelled_at { Faker::Time.between(from: 2.months.ago, to: 1.minute.ago) }
    end

    trait :missing_client_name do
      scheduled_at { Faker::Time.between(from: 2.months.ago, to: 1.minute.ago) }
      sent_at { scheduled_at + 15.seconds }
      arguments { [legal_aid_application.id, '', 'bob@wailing.jm'] }
    end
  end
end
