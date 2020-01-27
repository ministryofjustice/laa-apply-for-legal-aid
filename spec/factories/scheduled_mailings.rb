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

    trait :cancelled do
      scheduled_at { Faker::Time.between(from: 2.months.ago, to: 1.minute.ago) }
      cancelled_at { Faker::Time.between(from: 2.months.ago, to: 1.minute.ago) }
    end
  end
end
