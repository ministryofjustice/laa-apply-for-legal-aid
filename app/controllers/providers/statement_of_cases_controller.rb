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

      render :show unless save_continue_or_draft(@form)
    end

    private

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
  end
end
