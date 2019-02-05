module Providers
  class StatementOfCasesController < ProviderBaseController
    include ApplicationDependable
    include Flowable
    include Draftable
    before_action :authorize_legal_aid_application

    def show
      statement_of_case
    end

    def update
      statement_of_case.statement = statement_of_case_params[:statement]

      if statement_of_case.save || draft_selected?
        continue_or_draft
      else
        render :show
      end
    end

    private

    def statement_of_case_params
      params.require(:statement_of_case).permit(:statement)
    end

    def statement_of_case
      @statement_of_case ||= legal_aid_application.statement_of_case || legal_aid_application.build_statement_of_case
    end

    def authorize_legal_aid_application
      authorize legal_aid_application
    end
  end
end
