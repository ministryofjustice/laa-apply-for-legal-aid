module Providers
  module ApplicationMeritsTask
    class StatementOfCasesController < ProviderBaseController
      def show
        @form = ApplicationMeritsTask::StatementOfCaseChoiceForm.new(model: statement_of_case)
      end

      def update
        @form = StatementOfCaseChoiceForm.new(form_params)
        render :show unless update_task_save_continue_or_draft(:application, :statement_of_case, uploaded: @form.upload)
      end

    private

      def statement_of_case
        @statement_of_case ||= legal_aid_application.statement_of_case || legal_aid_application.build_statement_of_case
      end

      def form_params
        merge_with_model(statement_of_case) do
          params.expect(application_merits_task_statement_of_case: [:statement, { upload: [], typed: [] }])
        end
      end
    end
  end
end
