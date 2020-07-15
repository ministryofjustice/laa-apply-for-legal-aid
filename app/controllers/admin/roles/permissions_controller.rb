module Admin
  module Roles
    class PermissionsController < ApplicationController
      before_action :authenticate_admin_user!
      layout 'admin'.freeze

      def index; end
    end
  end
end
