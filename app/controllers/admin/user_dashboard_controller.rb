module Admin
  class UserDashboardController < ApplicationController
    before_action :authenticate_admin_user!
    layout 'admin'.freeze

    def index; end
  end
end
