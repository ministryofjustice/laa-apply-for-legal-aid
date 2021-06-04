FactoryBot.define do
  factory :gateway_evidence, class: 'GatewayEvidence' do
    legal_aid_application

    trait :with_original_file_attached do
      after :create do |soc|
        attachment = soc.legal_aid_application.attachments.create!(attachment_type: 'gateway_evidence',
                                                                   attachment_name: 'gateway_evidence')

        filepath = Rails.root.join('spec/fixtures/files/documents/hello_world.pdf')
        attachment.document.attach(io: File.open(filepath), filename: 'hello_world.pdf', content_type: 'application/pdf')
      end
    end

    trait :with_original_and_pdf_files_attached do
      after :create do |soc|
        pdf_attachment = soc.legal_aid_application.attachments.create!(attachment_type: 'gateway_evidence_pdf',
                                                                       attachment_name: 'gateway_evidence.pdf')

        attachment = soc.legal_aid_application.attachments.create!(pdf_attachment_id: pdf_attachment.id,
                                                                   attachment_type: 'gateway_evidence',
                                                                   attachment_name: 'gateway_evidence')

        filepath = Rails.root.join('spec/fixtures/files/documents/hello_world.pdf')
        pdf_attachment.document.attach(io: File.open(filepath), filename: 'hello_world.pdf', content_type: 'application/pdf')
        attachment.document.attach(io: File.open(filepath), filename: 'hello_world.pdf', content_type: 'application/pdf')
      end
    end
  end
end
