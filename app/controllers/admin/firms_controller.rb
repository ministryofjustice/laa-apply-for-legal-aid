module Admin
  class FirmsController < ApplicationController
    before_action :authenticate_admin_user!
    layout 'admin'.freeze

    def index
      @firms = Firm.order(:name)
    end
  end
end
