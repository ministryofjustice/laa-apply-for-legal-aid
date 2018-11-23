module Providers
  class CheckProviderAnswersController < BaseController
    include Providers::ApplicationDependable
    include Steppable

    def index
      @proceeding = @legal_aid_application.proceeding_types[0]
      @applicant = @legal_aid_application.applicant
      @address = html_address(@applicant.addresses[0])
    end

    def confirm
      legal_aid_application.provider_submit!
      CitizenEmailService.new(legal_aid_application).send_email
      flash[:notice] = 'Application completed. An e-mail will be sent to the citizen.'
      redirect_to next_step_url
    end

    private

    def html_address(address)
      [address.organisation, address.address_line_one, address.address_line_two, address.city, address.postcode].compact.reject(&:blank?).join('</br>').html_safe
    end
  end
end
