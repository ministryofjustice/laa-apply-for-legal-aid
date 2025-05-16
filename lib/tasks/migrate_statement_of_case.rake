def count_mismatch?(records, upload_target, text_target)
  upload_target -= remove_missing_socs?
  [
    records.where(upload: true).count != upload_target,
    records.where(typed: true).count != text_target,
  ].any?(true)
end

def remove_missing_socs?
  # sometimes, the statement of case is not created - a bug has been investigated and this ticket
  # is part of the hoped for fix - but it means there are at least 6 applications that have had a
  # file uploaded but have no linked ApplicationMeritsTask::StatementOfCase record in the database
  attachment_laa_ids = Attachment.statement_of_case.pluck(:legal_aid_application_id).uniq
  soc_laa_ids = ApplicationMeritsTask::StatementOfCase.where(upload: true).pluck(:legal_aid_application_id).uniq
  missing_socs = attachment_laa_ids - soc_laa_ids
  all_missing = missing_socs.map { |id| LegalAidApplication.find(id).statement_of_case.nil? }.all?(true)
  all_missing ? missing_socs.count : 0
end

namespace :migrate do
  desc "AP-5910: Migrate the statement of case type information"
  task statements_of_case: :environment do
    Rails.logger.info "== Before migration"
    records = ApplicationMeritsTask::StatementOfCase.all
    text_target = records.where.not(statement: "").count
    upload_target = Attachment.statement_of_case.pluck(:legal_aid_application_id).uniq.count
    Rails.logger.info "Affected applications: #{records.count}"
    Rails.logger.info "Number with text statement: #{text_target}"
    Rails.logger.info "Number with files uploaded: #{upload_target}"

    ActiveRecord::Base.transaction do
      records.find_each do |statement|
        typed = statement.statement.present?
        upload = statement.legal_aid_application.statement_of_case_uploaded?
        statement.update_columns({ typed:, upload: })
      end
      Rails.logger.info "== After migration"
      Rails.logger.info "Number with Typed: #{records.where(typed: true).count}"
      Rails.logger.info "Number with Upload: #{records.where(upload: true).count}"
      Rails.logger.info "Number with both: #{records.where(upload: true, typed: true).count}"

      raise StandardError, "Count mismatch" if count_mismatch?(records.reload, upload_target, text_target)
    end
  end
end
