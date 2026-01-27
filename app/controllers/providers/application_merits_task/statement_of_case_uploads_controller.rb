module Providers
  module ApplicationMeritsTask
    class StatementOfCaseUploadsController < ProviderBaseController
      def show
        @form = StatementOfCaseUploadForm.new(model: statement_of_case)
      end

      def update
        if upload_button_pressed?
          perform_upload
        elsif save_continue_or_draft(form)
          update_task(:application, :statement_of_case)
          convert_new_files_to_pdf
        else
          render :show
        end
      end

      def destroy
        original_file = delete_original_and_pdf_files
        @successfully_deleted = files_deleted_message(original_file.original_filename) unless original_file.nil?
        @form = StatementOfCaseUploadForm.new(model: statement_of_case)
        render :show
      end

      def list
        render partial: "shared/uploaded_files",
               locals: {
                 attachments: legal_aid_application.attachments.statement_of_case,
                 url: providers_legal_aid_application_statement_of_case_upload_path(@legal_aid_application),
               }
      end

    private

      def statement_of_case
        @statement_of_case ||= legal_aid_application.statement_of_case || legal_aid_application.build_statement_of_case
      end

      def form
        @form ||= StatementOfCaseUploadForm.new(statement_of_case_params)
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
        I18n.t("activemodel.attributes.uploaded_evidence_collection.file_deleted", file_name: deleted_file_name)
      end

      def successful_upload
        return if form.errors.present?

        I18n.t("activemodel.attributes.uploaded_evidence_collection.file_uploaded", file_name: form.original_file.original_filename)
      end

      def convert_new_files_to_pdf
        statement_of_case.original_attachments.each do |attachment|
          PDFConverterWorker.perform_async(attachment.id)
        end
      end

      def upload_button_pressed?
        params[:upload_button].present?
      end

      def statement_of_case_params
        return { model: statement_of_case } if params[:application_merits_task_statement_of_case].nil?

        params[:application_merits_task_statement_of_case] = { original_file: [] } unless params.key?(:application_merits_task_statement_of_case)
        merge_with_model(statement_of_case, provider_uploader: current_provider) do
          params.expect(application_merits_task_statement_of_case: %i[original_file])
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
end
