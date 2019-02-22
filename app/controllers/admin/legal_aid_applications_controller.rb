module Admin
  class LegalAidApplicationsController < ApplicationController
    before_action :authenticate_admin_user!
    def index
      @applications = LegalAidApplication.latest.limit(25)
    end
  end
end
