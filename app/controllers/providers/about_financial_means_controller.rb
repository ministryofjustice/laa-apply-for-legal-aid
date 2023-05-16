module Providers
  class AboutFinancialMeansController < ProviderBaseController
    def show
      @applicant = applicant
    end

    def update
      continue_or_draft
    end
  end
end
