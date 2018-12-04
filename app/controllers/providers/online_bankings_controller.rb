module Providers
  class OnlineBankingsController < ApplicationController
    include ApplicationDependable
    include Steppable

    def show
      @form = Applicants::UsesOnlineBankingForm.new(current_params)
    end

    def update
      @form = Applicants::UsesOnlineBankingForm.new(form_params)

      if @form.save
        next_step
      else
        render :show
      end
    end

    private

    def next_step
      if applicant.uses_online_banking?
        redirect_to next_step_url
      else
        render plain: '[PLACEHOLDER] Page directing provider to use CCMS'
      end
    end

    def applicant_params
      params.permit(applicant: :uses_online_banking)[:applicant] || {}
    end

    def form_params
      applicant_params.merge(model: applicant)
    end

    def current_params
      return unless applicant

      applicant.attributes.symbolize_keys.slice(:uses_online_banking)
    end
  end
end
