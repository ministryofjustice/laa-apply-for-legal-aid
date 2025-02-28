module UploadedEvidence
  class DeletionService < Base
    attr_reader :successfully_deleted, :upload_form

    def call
      original_file = delete_original_and_pdf_files
      @successfully_deleted = files_deleted_message(original_file.original_filename) unless original_file.nil?
      populate_upload_form
      @next_action = :show

      self
    end

    def uploaded_evidence_collection
      @uploaded_evidence_collection ||= legal_aid_application.uploaded_evidence_collection || legal_aid_application.build_uploaded_evidence_collection
    end

  private

    def delete_original_and_pdf_files
      original_attachment = Attachment.find(attachment_id)
      delete_attachment(Attachment.find(original_attachment.pdf_attachment_id)) if original_attachment.pdf_attachment_id.present?
      delete_attachment(original_attachment)
    rescue StandardError
      original_attachment
    end

    def files_deleted_message(deleted_file_name)
      I18n.t("activemodel.attributes.uploaded_evidence_collection.file_deleted", file_name: deleted_file_name)
    end

    def attachment_id
      params[:attachment_id]
    end

    def delete_attachment(attachment)
      attachment.document.purge_later
      attachment.destroy!
    end
  end
end
