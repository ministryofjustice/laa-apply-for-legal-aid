module Admin
  class RolesController < ApplicationController
    before_action :authenticate_admin_user!
    layout 'admin'.freeze

    def index
      @provider_firms = Firm.search(params[:search])
    end
  end
end
