module Providers
  class BankStatementsController < ProviderBaseController
    def show
      populate_form
    end

    def update
      if upload_button_pressed?
        perform_upload
      else
        render :show unless save_continue_or_draft(form)
      end
    end

    def destroy
      if upload_button_pressed?
        perform_upload
      else
        original_file = delete_original_and_pdf_files
        @successfully_deleted = files_deleted_message(original_file.original_filename) unless original_file.nil?
        populate_form
        render :show
      end
    end

    def list
      render partial: "providers/bank_statements/uploaded_files", locals: { attachments: legal_aid_application.attachments.bank_statement_evidence }
    end

  private

    def populate_form
      @form = BankStatementForm.new(model: bank_statement)
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
      I18n.t("activemodel.attributes.bank_statement.file_deleted", file_name: deleted_file_name)
    end

    def successful_upload
      return if form.errors.present?

      I18n.t("activemodel.attributes.bank_statement.file_uploaded", file_name: form.original_file.original_filename)
    end

    def upload_button_pressed?
      params[:upload_button].present?
    end

    def form
      @form ||= BankStatementForm.new(bank_statement_params)
    end

    def bank_statement_params
      params[:bank_statement] = { original_file: [], statement: nil } unless params.key?(:bank_statement)

      merge_with_model(bank_statement, provider_uploader: current_provider) do
        params.require(:bank_statement).permit(:original_file)
      end
    end

    def bank_statement
      @bank_statement ||= legal_aid_application.bank_statements.build
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
