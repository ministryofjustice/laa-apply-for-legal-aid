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
          action_for_next_step(options: { application: legal_aid_application, applicant: @form.model }),
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

    def current_step
      :email
    end
  end
end
