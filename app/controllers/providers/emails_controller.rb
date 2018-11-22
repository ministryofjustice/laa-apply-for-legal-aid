module Providers
  class EmailsController < ApplicationController
    include ApplicationDependable
    include Steppable

    def show
      @form = Applicants::EmailForm.new(model: applicant)
    end

    def update
      @form = Applicants::EmailForm.new(edit_params)

      if @form.save
        redirect_to(
          next_step_url,
          # TODO: Remove this - currently just a way of displaying a usable link
          notice: "Email link will be to: #{citizens_legal_aid_application_url(legal_aid_application.generate_secure_id)}"
        )
      else
        render :show
      end
    end

    private

    def edit_params
      email_params.merge(model: applicant)
    end

    def email_params
      params.require(:applicant).permit(:email)
    end

    def applicant
      @applicant ||= legal_aid_application.applicant
    end
  end
end
