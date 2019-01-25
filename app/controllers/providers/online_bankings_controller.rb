module Providers
  class OnlineBankingsController < BaseController
    include ApplicationDependable
    include Flowable

    def show
      authorize @legal_aid_application
      @form = Applicants::UsesOnlineBankingForm.new(model: applicant)
    end

    def update
      authorize @legal_aid_application
      @form = Applicants::UsesOnlineBankingForm.new(form_params)

      if @form.save
        go_forward
      else
        render :show
      end
    end

    private

    def applicant_params
      params.permit(applicant: :uses_online_banking)[:applicant] || {}
    end

    def form_params
      applicant_params.merge(model: applicant)
    end
  end
end
