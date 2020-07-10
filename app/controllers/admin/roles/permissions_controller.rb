module Admin
  module Roles
    class PermissionsController < ApplicationController
      before_action :authenticate_admin_user!
      layout 'admin'.freeze

      def index
        provider_firms
      end

      private

      def provider_firms
        @provider_firms ||= Firm.all
      end
    end
  end
end
