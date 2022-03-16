module Providers
  # TODO: refactor this controller once the validation ticket AP-2739 and this one AP-2872
  # have been merged. Then we can remove the rubocop disable tag
  class UploadedEvidenceCollectionsController < ProviderBaseController
    def show
      RequiredDocumentCategoryAnalyser.call(legal_aid_application)
      populate_upload_form
    end

    def update
      if button_pressed?(:upload_button)
        perform_upload
      elsif button_pressed?(:draft_button)
        populate_submission_form
        save_continue_or_draft(submission_form)
      elsif button_pressed?(:delete_button)
        destroy
      elsif save_or_continue
        convert_new_files_to_pdf
      else
        populate_upload_form
        render :show
      end
    end

    def destroy
      original_file = delete_original_and_pdf_files
      @successfully_deleted = files_deleted_message(original_file.original_filename) unless original_file.nil?
      populate_upload_form
      render :show
    end

    def list
      RequiredDocumentCategoryAnalyser.call(legal_aid_application)
      attachment_type_options
      render partial: "uploaded_files", locals: { attachments: uploaded_evidence_collection.original_attachments }
    end

  private

    def required_documents
      @required_documents = legal_aid_application.required_document_categories
    end

    def attachment_type_options
      @attachment_type_options = required_documents.map { |rd| [rd, rd.humanize] }
      @attachment_type_options << %w[uncategorised Uncategorised]
    end

    def save_or_continue
      no_files = params[:uploaded_evidence_collection].nil?
      update_attachment_type unless no_files
      populate_submission_form
      return false unless submission_form.model.valid?

      if no_files
        legal_aid_application.reload
        continue_or_draft
      else
        save_continue_or_draft(submission_form)
      end
    end

    def populate_upload_form
      required_documents
      @upload_form = Providers::UploadedEvidenceCollectionForm.new(model: uploaded_evidence_collection)
      attachment_type_options
      evidence_type_translation
      mandatory_evidence_errors
      categorisation_errors
    end

    def populate_submission_form
      @submission_form = Providers::UploadedEvidenceSubmissionForm.new(model: uploaded_evidence_collection)
    end

    def perform_upload
      upload_form.upload_button_pressed = true
      if upload_form.valid? && upload_form.save
        @successful_upload = successful_upload
      else
        @error_message = error_message
      end
      RequiredDocumentCategoryAnalyser.call(legal_aid_application)
      required_documents
      attachment_type_options
      render :show
    end

    def convert_new_files_to_pdf
      return if uploaded_evidence_collection.nil?

      uploaded_evidence_collection.original_attachments.each do |attachment|
        PdfConverterWorker.perform_async(attachment.id)
      end
    end

    def button_pressed?(button)
      # does the parameter exist?
      return false if params[button].nil?

      # The current helper renders the buttons with a content value
      # rather than an attribute therefore it will be an empty string
      params[button].empty?
    end

    def upload_form
      @upload_form ||= Providers::UploadedEvidenceCollectionForm.new(uploaded_evidence_collection_params)
    end

    def submission_form
      @submission_form ||= Providers::UploadedEvidenceSubmissionForm.new(uploaded_evidence_collection_params)
    end

    def update_attachment_type
      params[:uploaded_evidence_collection].each do |att_id, new_att_type|
        Attachment.find(att_id).update(attachment_type: new_att_type)
      end
    end

    def uploaded_evidence_collection_params
      params[:uploaded_evidence_collection] = { original_file: [] } unless params.key?(:uploaded_evidence_collection)
      merge_with_model(uploaded_evidence_collection, provider_uploader: current_provider) do
        params.require(:uploaded_evidence_collection).permit(:original_file)
      end
    end

    def uploaded_evidence_collection
      @uploaded_evidence_collection ||= legal_aid_application.uploaded_evidence_collection || legal_aid_application.build_uploaded_evidence_collection
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

    def error_message
      return if upload_form.errors.blank?

      "#{I18n.t('accessibility.problem_text')} #{upload_form.errors.messages[:original_file].first}"
    end

    def mandatory_evidence_errors
      @mandatory_evidence_errors = @uploaded_evidence_collection.errors.errors.select { |error| error.options[:mandatory_evidence] }
    end

    def categorisation_errors
      @categorisation_errors = @uploaded_evidence_collection.errors.errors.reject { |error| error.options[:mandatory_evidence] }
    end

    def files_deleted_message(deleted_file_name)
      I18n.t("activemodel.attributes.uploaded_evidence_collection.file_deleted", file_name: deleted_file_name)
    end

    def successful_upload
      return if upload_form.errors.present?

      I18n.t("activemodel.attributes.uploaded_evidence_collection.file_uploaded", file_name: "File")
    end

    def evidence_type_translation
      return unless required_documents.include?("benefit_evidence")

      @evidence_type_translation = I18n.t(".shared.forms.received_benefit_confirmation.form.providers.received_benefit_confirmations.#{passporting_benefit}")
    end

    def passporting_benefit
      legal_aid_application.dwp_override.passporting_benefit
    end
  end
end
