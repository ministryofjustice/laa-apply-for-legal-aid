module Providers
  class NoNationalInsuranceNumbersController < ProviderBaseController
    include ApplicantDetailsCheckable
    include BenefitCheckSkippable
    include DWPOutcomeHelper

    def show
      @applicant = legal_aid_application.applicant

      if @applicant.national_insurance_number?
        redirect_to providers_legal_aid_application_dwp_result_path(legal_aid_application)
      else
        reset_confirm_dwp_status(legal_aid_application)
        details_checked! unless details_checked?
        mark_as_benefit_check_skipped!("no_national_insurance_number")
        render :show
      end
    end

    def update
      update_confirm_dwp_status(legal_aid_application, true)
      continue_or_draft
    end
  end
end
