module Admin
  module Roles
    class PermissionsController < ApplicationController
      before_action :authenticate_admin_user!
      layout 'admin'.freeze

      def show
        firm
        permissions
      end

      def create

      end

      private

      def permissions
        @permissions ||= Permission.all
      end

      def firm
        @firm ||= Firm.find(params[:id])
      end
    end
  end
end
