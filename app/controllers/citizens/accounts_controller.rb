module Citizens
  class AccountsController < CitizenBaseController
    def index
      @applicant_banks = current_applicant.bank_providers.collect do |bank_provider|
        ApplicantAccountPresenter.new(bank_provider)
      end
    end
  end
end
