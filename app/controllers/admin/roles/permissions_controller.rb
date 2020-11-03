module Admin
  module Roles
    class PermissionsController < ApplicationController
      before_action :authenticate_admin_user!
      layout 'admin'.freeze

      def show
        firm
        permissions
      end

      def update
        firm.update!(firm_params)
        redirect_to admin_root_path, notice: 'Permissions have been updated'
        #  should this redirect take you back to the admin_roles_path instead, useful if multiple firms are being updated
      end

      private

      def permissions
        @permissions ||= Permission.all
      end

      def firm
        @firm ||= Firm.find(params[:id])
      end

      def firm_params
        params[:firm] = { permission_ids: [] } if params[:firm].nil?
        params.require(:firm).permit(permission_ids: [])
      end
    end
  end
end
