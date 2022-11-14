module Providers
  class NoNationalInsuranceNumbersController < ProviderBaseController
    include ApplicantDetailsCheckable

    def show
      @applicant = legal_aid_application.applicant

      if @applicant.national_insurance_number?
        redirect_to providers_legal_aid_application_check_benefits_path(legal_aid_application)
      else
        details_checked! unless details_checked?
        mark_as_benefit_check_skipped!
        render :show
      end
    end

    def update
      continue_or_draft
    end

  private

    def mark_as_benefit_check_skipped!
      legal_aid_application.create_benefit_check_result!(result: "skipped:no_national_insurance_number")
    end
  end
end
