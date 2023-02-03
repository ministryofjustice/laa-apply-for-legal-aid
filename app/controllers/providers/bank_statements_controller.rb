module Providers
  class BankStatementsController < ProviderBaseController
    skip_back_history_for :list

    before_action :set_form, only: %i[show update destroy]

    def show
      legal_aid_application.set_transaction_period
      legal_aid_application.provider_assess_means! unless checking_answers?
    end

    def update
      if upload_button_pressed?
        perform_upload
      elsif save_continue_or_draft(form)
        nil
      else
        render :show
      end
    end

    def destroy
      original_file = delete_original_and_pdf_files
      @successfully_deleted = files_deleted_message(original_file.original_filename) unless original_file.nil?
      render :show
    end

    def list
      render partial: "providers/bank_statements/uploaded_files", locals: { attachments: legal_aid_application.attachments.bank_statement_evidence }
    end

  private

    def checking_answers?
      legal_aid_application.checking_non_passported_means? or legal_aid_application.checking_means_income?
    end

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

    def set_form
      @form = BankStatementForm.new(bank_statement_form_params)
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
      I18n.t("activemodel.attributes.providers/bank_statement_form.file_deleted", file_name: deleted_file_name)
    end

    def successful_upload
      return if form.errors.present?

      I18n.t("activemodel.attributes.providers/bank_statement_form.file_uploaded", file_name: form.original_file.original_filename)
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
      attachment_params[:attachment_id]
    end

    def attachment_params
      params.permit(:attachment_id)
    end
  end
end
