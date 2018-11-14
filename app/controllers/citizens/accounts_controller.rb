module Citizens
  class AccountsController < ApplicationController
    before_action :authenticate_applicant!

    def index
      @applicant_banks = current_applicant.bank_providers.collect do |bank_provider|
        ApplicantAccountPresenter.new(bank_provider)
      end
    end
  end
end
