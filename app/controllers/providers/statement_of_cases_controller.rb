module Providers
  class StatementOfCasesController < ProviderBaseController
    def show
      @form = StatementOfCases::StatementOfCaseForm.new(model: statement_of_case)
    end

    def update
      if upload_button_pressed? # javascript is unavailable
        perform_upload
      elsif request.xhr? # a file selected for upload from the dialog box
        perform_xhr_request
      elsif save_continue_or_draft(form)
        convert_new_files_to_pdf
      else
        render :show
      end
    end

    def destroy
      delete_original_and_pdf_files

      if request.xhr?
        head :ok
      else
        redirect_to [:providers, legal_aid_application, :statement_of_case]
      end
    end

    private

    def perform_xhr_request
      form.save
      render json: {
        error_summary: error_summary,
        uploaded_files_table: uploaded_files_table,
        errors: form.errors
      }
    end

    def error_summary
      render_to_string(
        partial: 'shared/forms/error_summary',
        locals: { model: form }
      )
    end

    def uploaded_files_table
      render_to_string(
        partial: 'providers/statement_of_cases/uploaded_files',
        locals: { attachments: form.model.original_attachments }
      )
    end

    def perform_upload
      form.upload_button_pressed = true
      if form.save
        redirect_to providers_legal_aid_application_statement_of_case_path
      else
        render :show
      end
    end

    def convert_new_files_to_pdf
      statement_of_case.original_attachments.each do |attachment|
        PdfConverterWorker.perform_async(attachment.id)
      end
    end

    def upload_button_pressed?
      params[:upload_button].present?
    end

    def form
      @form ||= StatementOfCases::StatementOfCaseForm.new(statement_of_case_params)
    end

    def statement_of_case_params
      merge_with_model(statement_of_case, provider_uploader: current_provider) do
        params.require(:statement_of_case).permit(:statement, original_files: [])
      end
    end

    def statement_of_case
      @statement_of_case ||= legal_aid_application.statement_of_case || legal_aid_application.build_statement_of_case
    end

    def delete_original_and_pdf_files
      original_attachment = Attachment.find(attachment_id)
      delete_attachment(Attachment.find(original_attachment.pdf_attachment_id)) if original_attachment.pdf_attachment_id.present?
      delete_attachment(original_attachment)
    rescue StandardError
      nil
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
