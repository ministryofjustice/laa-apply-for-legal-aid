FactoryBot.define do
  factory :gateway_evidence, class: 'GatewayEvidence' do
    legal_aid_application

    trait :with_original_file_attached do
      after :create do |ge|
        attachment = ge.legal_aid_application.attachments.create!(attachment_type: 'gateway_evidence',
                                                                  attachment_name: 'gateway_evidence')

        filepath = Rails.root.join('spec/fixtures/files/documents/hello_world.pdf')
        attachment.document.attach(io: File.open(filepath), filename: 'hello_world.pdf', content_type: 'application/pdf')
      end
    end

    trait :with_multiple_files_attached do
      after :create do |ge|
        attachment = ge.legal_aid_application.attachments.create!(attachment_type: 'gateway_evidence',
                                                                  attachment_name: 'gateway_evidence_2')
        attachment1 = ge.legal_aid_application.attachments.create!(attachment_type: 'gateway_evidence',
                                                                   attachment_name: 'gateway_evidence_3')
        attachment2 = ge.legal_aid_application.attachments.create!(attachment_type: 'gateway_evidence',
                                                                   attachment_name: 'gateway_evidence_4')

        filepath = Rails.root.join('spec/fixtures/files/documents/hello_world.pdf')
        attachment.document.attach(io: File.open(filepath), filename: 'hello_world.pdf', content_type: 'application/pdf')
        attachment1.document.attach(io: File.open(filepath), filename: 'hello_world1.pdf', content_type: 'application/pdf')
        attachment2.document.attach(io: File.open(filepath), filename: 'hello_world2.pdf', content_type: 'application/pdf')
      end
    end

    trait :with_original_and_pdf_files_attached do
      after :create do |ge|
        pdf_attachment = ge.legal_aid_application.attachments.create!(attachment_type: 'gateway_evidence_pdf',
                                                                      attachment_name: 'gateway_evidence.pdf')

        attachment = ge.legal_aid_application.attachments.create!(pdf_attachment_id: pdf_attachment.id,
                                                                  attachment_type: 'gateway_evidence',
                                                                  attachment_name: 'gateway_evidence')

        filepath = Rails.root.join('spec/fixtures/files/documents/hello_world.pdf')
        pdf_attachment.document.attach(io: File.open(filepath), filename: 'hello_world.pdf', content_type: 'application/pdf')
        attachment.document.attach(io: File.open(filepath), filename: 'hello_world.pdf', content_type: 'application/pdf')
      end
    end
  end
end
