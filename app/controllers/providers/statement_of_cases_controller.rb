module Providers
  class StatementOfCasesController < ProviderBaseController
    before_action :authorize_legal_aid_application

    def show
      @form = StatementOfCases::StatementOfCaseForm.new(model: statement_of_case)
    end

    def update
      @form = StatementOfCases::StatementOfCaseForm.new(statement_of_case_params)
      if upload_button_pressed?
        @form.upload_button_pressed = true
        @form.save
        render :show
      end

      return if performed?

      if save_continue_or_draft(@form)
        convert_new_files_to_pdf
      else
        render :show
      end
    end

    def destroy
      delete_original_file
      delete_pdf_file
      redirect_to [:providers, legal_aid_application, :statement_of_case]
    end

    private

    def convert_new_files_to_pdf
      statement_of_case.original_files.each do |original_file|
        PdfFile.convert_original_file(original_file.id)
      end
    end

    def upload_button_pressed?
      params[:upload_button].present?
    end

    def statement_of_case_params
      merge_with_model(statement_of_case, provider_uploader: current_provider) do
        params.require(:statement_of_case).permit(:statement, original_files: [])
      end
    end

    def statement_of_case
      @statement_of_case ||= legal_aid_application.statement_of_case || legal_aid_application.build_statement_of_case
    end

    def authorize_legal_aid_application
      authorize legal_aid_application
    end

    def delete_original_file
      file = statement_of_case.original_files.find_by(id: original_file_id)
      if file
        file.purge
      else
        Rails.logger.error "Unable to remove original file. Not found: #{original_file_id}"
      end
    end

    def delete_pdf_file
      PdfFile.where(original_file_id: original_file_id).destroy_all
    end

    def original_file_id
      params[:original_file_id]
    end
  end
end
