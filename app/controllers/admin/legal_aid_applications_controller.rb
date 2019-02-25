module Admin
  class LegalAidApplicationsController < ApplicationController
    before_action :authenticate_admin_user!
    def index
      @applications = LegalAidApplication.latest.limit(25)
    end

    def destroy_all
      LegalAidApplication.destroy_all
      Applicant.destroy_all
      redirect_to action: :index
    end
  end
end
