module Providers
  class HasNationalInsuranceNumbersController < ProviderBaseController
    reviewed_by :legal_aid_application, :check_provider_answers

    def show
      @form = Applicants::HasNationalInsuranceNumberForm.new(model: applicant)
    end

    def update
      unreview!

      @form = Applicants::HasNationalInsuranceNumberForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

  private

    def applicant
      legal_aid_application.applicant
    end

    def form_params
      merge_with_model(applicant) do
        params.expect(applicant: %i[has_national_insurance_number national_insurance_number])
      end
    end
  end
end
