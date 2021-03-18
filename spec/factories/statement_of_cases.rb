FactoryBot.define do
  factory :statement_of_case, class: 'ApplicationMeritsTask::StatementOfCase' do
    legal_aid_application

    statement { Faker::Lorem.paragraph }

    trait :with_empty_text do
      statement { nil }
    end

    trait :with_original_file_attached do
      after :create do |soc|
        attachment = soc.legal_aid_application.attachments.create!(attachment_type: 'statement_of_case',
                                                                   attachment_name: 'statement_of_case')

        filepath = Rails.root.join('spec/fixtures/files/documents/hello_world.pdf')
        attachment.document.attach(io: File.open(filepath), filename: 'hello_world.pdf', content_type: 'application/pdf')
      end
    end

    trait :with_original_and_pdf_files_attached do
      after :create do |soc|
        pdf_attachment = soc.legal_aid_application.attachments.create!(attachment_type: 'statement_of_case_pdf',
                                                                       attachment_name: 'statement_of_case.pdf')

        attachment = soc.legal_aid_application.attachments.create!(pdf_attachment_id: pdf_attachment.id,
                                                                   attachment_type: 'statement_of_case',
                                                                   attachment_name: 'statement_of_case')

        filepath = Rails.root.join('spec/fixtures/files/documents/hello_world.pdf')
        pdf_attachment.document.attach(io: File.open(filepath), filename: 'hello_world.pdf', content_type: 'application/pdf')
        attachment.document.attach(io: File.open(filepath), filename: 'hello_world.pdf', content_type: 'application/pdf')
      end
    end
  end
end
