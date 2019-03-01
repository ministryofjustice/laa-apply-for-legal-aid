FactoryBot.define do
  factory :statement_of_case do
    legal_aid_application

    statement { Faker::Lorem.paragraph }

    trait :with_empty_text do
      statement { nil }
    end

    trait :with_attached_files do
      after :create do |soc|
        filepath = "#{Rails.root}/spec/fixtures/files/lorem_ipsum.pdf"
        soc.original_files.attach(io: File.open(filepath), filename: 'lorem_ipsum.pdf', content_type: 'application/pdf')
      end
    end
  end
end
