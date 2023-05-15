module Providers
  class AboutFinancialMeansController < ProviderBaseController
    def show
      @name = full_name
      @applicant = applicant
    end

    def update
      continue_or_draft
    end

  private

    def full_name
      "#{applicant.first_name} #{applicant.last_name}"
    end
  end
end
