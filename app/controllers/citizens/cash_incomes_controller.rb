module Citizens
  class CashIncomesController < CitizenBaseController
    def show
      legal_aid_application
      @none_selected = legal_aid_application.no_cash_income_types_selected?
    end
  end
end
