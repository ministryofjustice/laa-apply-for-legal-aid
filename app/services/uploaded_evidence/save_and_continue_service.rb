module UploadedEvidence
  class SaveAndContinueService < Base
    def call
      if save_or_continue
        convert_new_files_to_pdf
      else
        populate_upload_form
        @next_action = :show
      end

      self
    end

  private

    def save_or_continue
      no_files = params[:uploaded_evidence_collection].nil?
      update_attachment_type unless no_files
      populate_submission_form
      return false unless submission_form.model.valid?

      if no_files
        legal_aid_application.reload
        @next_action = :continue_or_draft
      else
        @next_action = :save_continue_or_draft
      end
    end

    def convert_new_files_to_pdf
      return if uploaded_evidence_collection.nil?

      uploaded_evidence_collection.original_attachments.each do |attachment|
        PDFConverterWorker.perform_async(attachment.id)
      end
    end
  end
end
