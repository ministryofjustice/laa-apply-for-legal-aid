module Providers
  class GatewayEvidencesController < ProviderBaseController
    def show
      populate_form
    end

    def update
      if upload_button_pressed?
        perform_upload
      elsif save_or_continue
        convert_new_files_to_pdf
      else
        render :show
      end
    end

    def destroy
      original_file = delete_original_and_pdf_files
      @successfully_deleted = files_deleted_message(original_file.attachment_name) unless original_file.nil?
      populate_form
      render :show
    end

    private

    def save_or_continue
      if form.files?
        save_continue_or_draft(form)
      else
        legal_aid_application.reload
        continue_or_draft
      end
    end

    def populate_form
      @form = Providers::GatewayEvidenceForm.new(model: gateway_evidence)
    end

    def perform_upload
      form.upload_button_pressed = true
      if form.valid? && form.save
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
      I18n.t('activemodel.attributes.gateway_evidence.file_deleted', file_name: deleted_file_name)
    end

    def successful_upload
      return if form.errors.present?

      I18n.t('activemodel.attributes.gateway_evidence.file_uploaded', file_name: 'File')
    end

    def convert_new_files_to_pdf
      gateway_evidence.original_attachments.each do |attachment|
        PdfConverterWorker.perform_async(attachment.id)
      end
    end

    def upload_button_pressed?
      params[:upload_button].present?
    end

    def form
      @form ||= Providers::GatewayEvidenceForm.new(gateway_evidence_params)
    end

    def gateway_evidence_params
      params[:gateway_evidence] = { original_file: [] } unless params.key?(:gateway_evidence)
      merge_with_model(gateway_evidence, provider_uploader: current_provider) do
        params.require(:gateway_evidence).permit(:original_file)
      end
    end

    def gateway_evidence
      @gateway_evidence ||= legal_aid_application.gateway_evidence || legal_aid_application.build_gateway_evidence
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
      attachment.destroy
    end

    def attachment_id
      params[:attachment_id]
    end
  end
end
