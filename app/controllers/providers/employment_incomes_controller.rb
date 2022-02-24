module Providers
  class EmploymentIncomesController < ProviderBaseController
    before_action :employments

    def show
      @applicant = applicant
      @form = LegalAidApplications::EmploymentIncomeForm.new(model: legal_aid_application)
    end

    def update
      @applicant = applicant
      @form = LegalAidApplications::EmploymentIncomeForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

    private

    def applicant
      @applicant ||= legal_aid_application.applicant
    end

    def employments
      @employments = @legal_aid_application.employments
    end

    def form_params
      merge_with_model(legal_aid_application) do
        return {} unless params[:legal_aid_application]

        params.require(:legal_aid_application).permit(:extra_employment_information, :extra_employment_information_details)
      end
    end
  end
end
