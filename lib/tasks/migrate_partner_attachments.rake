namespace :migrate do
  desc "AP-5141 migrate attachment names after length exceeded CCMS limits"

  task partner_attachments: :environment do
    changes = {
      partner_bank_statement_evidence: "part_bank_state_evidence",
      partner_bank_statement_evidence_pdf: "part_bank_state_evidence_pdf",
      partner_employment_evidence: "part_employ_evidence",
      partner_employment_evidence_pdf: "part_employ_evidence_pdf",
    }

    attachments = Attachment.where(attachment_type: changes.keys)
    documents = CCMS::SubmissionDocument.where(document_type: changes.keys)
    Rails.logger.info "Migrating filenames"
    Rails.logger.info "----------------------------------------"
    Rails.logger.info "Affected attachments   : #{attachments.count}"
    Rails.logger.info "Affected documents   : #{documents.count}"
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Benchmark.benchmark do |bm|
      bm.report("Migrate:") do
        ActiveRecord::Base.transaction do
          attachments.each do |file|
            file.attachment_type = changes[file.attachment_type.to_sym]
            file.save!(touch: false) # this prevents the updated_at date being changed and delaying purging of stale records
          end
          raise StandardError, "Not all attachments updated" if Attachment.where(attachment_type: changes.keys).count.positive?

          documents.each do |file|
            file.document_type = changes[file.document_type.to_sym]
            file.save!(touch: false) # this prevents the updated_at date being changed and delaying purging of stale records
          end
          raise StandardError, "Not all documents updated" if CCMS::SubmissionDocument.where(document_type: changes.keys).count.positive?
        end
      end
    end
    Rails.logger.info "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Rails.logger.info "Attachments updated    : #{Attachment.where(attachment_type: changes.values).count}"
    Rails.logger.info "Documents updated      : #{CCMS::SubmissionDocument.where(document_type: changes.values).count}"
    Rails.logger.info "Attachments not updated: #{Attachment.where(attachment_type: changes.keys).count}"
    Rails.logger.info "Documents not updated  : #{CCMS::SubmissionDocument.where(document_type: changes.keys).count}"
    Rails.logger.info "----------------------------------------"
  end
end
