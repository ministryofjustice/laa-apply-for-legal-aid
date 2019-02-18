module Providers
  class StatementOfCasesController < ProviderBaseController
    before_action :authorize_legal_aid_application

    def show
      @form = StatementOfCases::StatementOfCaseForm.new(model: statement_of_case)
    end

    def update
      @form = StatementOfCases::StatementOfCaseForm.new(statement_of_case_params)

      if save_continue_or_draft(@form)
        convert_new_file_to_pdf if statement_of_case_params[:original_file].present?
      else
        render :show
      end
    end

    private

    def convert_new_file_to_pdf
      StatementOfCasePdfConverterWorker.perform_async(statement_of_case.id)
    end

    def statement_of_case_params
      params
        .require(:statement_of_case)
        .permit(:statement, :original_file)
        .merge(model: statement_of_case, provider_uploader: current_provider)
    end

    def statement_of_case
      @statement_of_case ||= legal_aid_application.statement_of_case || legal_aid_application.build_statement_of_case
    end

    def authorize_legal_aid_application
      authorize legal_aid_application
    end
  end
end
