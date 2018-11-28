module Providers
  class EmailsController < ApplicationController
    include ApplicationDependable
    include Steppable

    def show
      @form = Applicants::EmailForm.new(current_params)
    end

    def update
      @form = Applicants::EmailForm.new(update_params)

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

    def update_params
      email_params.merge(model: applicant)
    end

    def email_params
      params.require(:applicant).permit(:email)
    end

    def current_params
      return nil unless applicant
      applicant.attributes.symbolize_keys.slice(:email)
    end
  end
end
