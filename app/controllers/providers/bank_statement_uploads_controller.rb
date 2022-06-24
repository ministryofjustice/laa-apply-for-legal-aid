module Providers
  class BankStatementUploadsController < ProviderBaseController
    def show
      populate_form
    end

    def update
      if upload_button_pressed?
        perform_upload
      else
        # TODO: needed?
        # update_task(:application, :bank_statement_uploads)
        render :show unless save_continue_or_draft(@form)
      end
    end

    def destroy
      original_file = delete_original_and_pdf_files
      @successfully_deleted = files_deleted_message(original_file.original_filename) unless original_file.nil?
      populate_form
      render :show
    end

    def list
      render partial: "providers/bank_statement_uploads/uploaded_files", locals: { attachments: legal_aid_application.attachments.client_bank_statement }
    end

  private

    def task_list_should_update?
      application_has_task_list? && !draft_selected?
    end

    def populate_form
      @form = BankStatementUploadForm.new(model: legal_aid_application.bank_statement_uploads.build)
    end

    def perform_upload
      form.upload_button_pressed = true
      if form.save
        @successful_upload = successful_upload
      else
        @error_message = error_message
      end
      render :show
    end

    def error_message
      return if form.errors.blank?

      "#{I18n.t('accessibility.problem_text')} #{form.errors.messages[:original_file].first}"
    end

    def files_deleted_message(deleted_file_name)
      I18n.t("activemodel.attributes.bank_statement_uploads.file_deleted", file_name: deleted_file_name)
    end

    def successful_upload
      return if form.errors.present?

      I18n.t("activemodel.attributes.bank_statement_upload.file_uploaded", file_name: form.original_file.original_filename)
    end

    def upload_button_pressed?
      params[:upload_button].present?
    end

    def form
      @form ||= BankStatementUploadForm.new(bank_statement_upload_params)
    end

    def bank_statement_upload_params
      params[:bank_statement_upload] = { original_file: [], statement: nil } unless params.key?(:bank_statement_upload)

      merge_with_model(bank_statement_upload, provider_uploader: current_provider) do
        params.require(:bank_statement_uploads).permit(:statement, :original_file)
      end
    end

    def delete_original_and_pdf_files
      original_attachment = Attachment.find(attachment_id)
      delete_attachment(Attachment.find(original_attachment.pdf_attachment_id)) if original_attachment.pdf_attachment_id.present?
      delete_attachment(original_attachment)
    rescue StandardError
      original_attachment
    end

    def delete_attachment(attachment)
      attachment.document.purge_later
      attachment.destroy!
    end

    def attachment_id
      params[:attachment_id]
    end
  end
end
