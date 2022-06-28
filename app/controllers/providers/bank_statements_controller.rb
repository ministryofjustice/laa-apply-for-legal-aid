module Providers
  class BankStatementsController < ProviderBaseController
    skip_back_history_for :list

    def show
      populate_form
    end

    def update
      if upload_button_pressed?
        perform_upload
      elsif save_continue_or_draft(form)
        nil
        # TODO: convert_new_files_to_pdf
      else
        render :show
      end
    end

    def destroy
      original_file = delete_original_and_pdf_files
      @successfully_deleted = files_deleted_message(original_file.original_filename) unless original_file.nil?
      populate_form
      render :show
    end

    def list
      render partial: "providers/bank_statements/uploaded_files", locals: { attachments: legal_aid_application.attachments.bank_statement_evidence }
    end

  private

    def upload_button_pressed?
      params.key?(:upload_button)
    end

    def perform_upload
      form.upload_button_pressed = true
      if form.upload
        @successful_upload = successful_upload
      else
        @error_message = error_message
      end
      render :show
    end

    # we do not use the model here but it needs to be passed to keep inheritance happy :)
    def populate_form
      @form = BankStatementForm.new(model: bank_statement)
    end

    def bank_statement
      @bank_statement ||= legal_aid_application.bank_statements.build
    end

    def form
      @form ||= BankStatementForm.new(bank_statement_form_params)
    end

    # original_file only needed for non-JS upload
    def bank_statement_form_params
      params.permit(:legal_aid_application_id, :original_file)
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

    # def convert_new_files_to_pdf
    #   statement_of_case.original_attachments.each do |attachment|
    #     PdfConverterWorker.perform_async(attachment.id)
    #   end
    # end

    def delete_original_and_pdf_files
      original_attachment = Attachment.find(attachment_id)
      delete_attachment(Attachment.find(original_attachment.pdf_attachment_id)) if original_attachment.pdf_attachment_id.present?
      delete_attachment(original_attachment)
    rescue StandardError
      original_attachment
    end

    def delete_attachment(attachment)
      bank_statement = legal_aid_application.bank_statements.find_by(attachment_id: attachment.id)
      bank_statement.destroy!
      attachment.document.purge_later
      attachment.destroy!
    end

    def attachment_id
      params[:attachment_id]
    end
  end
end
