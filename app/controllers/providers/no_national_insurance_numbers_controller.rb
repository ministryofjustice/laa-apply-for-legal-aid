module Providers
  class NoNationalInsuranceNumbersController < ProviderBaseController
    include ApplicantDetailsCheckable
    include BenefitCheckSkippable

    def show
      @applicant = legal_aid_application.applicant

      if @applicant.national_insurance_number?
        redirect_to providers_legal_aid_application_check_benefit_path(legal_aid_application)
      else
        details_checked! unless details_checked?
        mark_as_benefit_check_skipped!("no_national_insurance_number")
        render :show
      end
    end

    def update
      continue_or_draft
    end
  end
end
