FactoryBot.define do
  factory :scheduled_mailing do
    legal_aid_application

    mailer_klass { 'SubmitApplicationReminderMailer' }
    mailer_method { 'notify_provider' }
    status { 'processing' }
    addressee { Faker::Internet.safe_email }
    arguments { [legal_aid_application.id, 'Bob Marley', 'bob@wailing.jm'] }
    scheduled_at { Faker::Time.between(from: 1.minute.from_now, to: 2.months.from_now) }
    govuk_message_id { SecureRandom.uuid }

    trait :waiting do
      status { 'waiting' }
      govuk_message_id { nil }
    end

    trait :due do
      scheduled_at { Faker::Time.between(from: 2.months.ago, to: 1.minute.ago) }
      status { 'waiting' }
      govuk_message_id { nil }
    end

    trait :due_later do
      scheduled_at { Faker::Time.between(from: 1.minute.from_now, to: 2.months.from_now) }
      status { 'waiting' }
      govuk_message_id { nil }
    end

    trait :sent do
      scheduled_at { Faker::Time.between(from: 2.months.ago, to: 1.minute.ago) }
      sent_at { scheduled_at + 15.seconds }
      status { 'delivered' }
    end

    trait :provider_financial_reminder do
      mailer_klass { 'SubmitProviderFinancialReminderMailer' }
      mailer_method { 'notify_provider' }
      scheduled_at { Faker::Time.between(from: 2.months.ago, to: 1.minute.ago) }
    end

    trait :citizen_financial_reminder do
      mailer_klass { 'SubmitCitizenFinancialReminderMailer' }
      mailer_method { 'notify_citizen' }
      scheduled_at { Faker::Time.between(from: 2.months.ago, to: 1.minute.ago) }
    end

    trait :cancelled do
      scheduled_at { Faker::Time.between(from: 2.months.ago, to: 1.minute.ago) }
      cancelled_at { Faker::Time.between(from: 2.months.ago, to: 1.minute.ago) }
    end

    trait :always_eligible_for_delivery do
      mailer_klass { 'ResendLinkRequestMailer' }
      mailer_method { 'notify' }
    end

    trait :failed do
      status { 'permanent-failure' }
    end

    trait :delivered do
      status { 'delivered' }
    end

    trait :processing do
      status { 'processing' }
      govuk_message_id { nil }
    end

    trait :created do
      status { 'created' }
    end

    trait :sending do
      status { 'sending' }
    end

    trait :citizen_start_email do
      mailer_klass { 'NotifyMailer' }
      mailer_method { 'citizen_start_email' }
    end
  end
end
