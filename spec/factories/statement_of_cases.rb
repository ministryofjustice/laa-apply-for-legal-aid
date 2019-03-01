FactoryBot.define do
  factory :statement_of_case do
    legal_aid_application

    statement { Faker::Lorem.paragraph }

    trait :with_empty_text do
      statement { nil }
    end

    trait :with_attached_files do
      after :create do |soc|
        filepath = "#{Rails.root}/spec/fixtures/files/documents/hello_world.pdf"
        soc.original_files.attach(io: File.open(filepath), filename: 'hello_world.pdf', content_type: 'application/pdf')
        PdfFile.create!(original_file_id: soc.original_files.last.id)
      end
    end
  end
end
