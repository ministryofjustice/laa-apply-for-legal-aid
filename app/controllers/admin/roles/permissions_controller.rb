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
        redirect_to admin_settings_path, notice: 'Permissions have been updated'
        # if firm.update(firm_params)
        #   firm.update!(firm_params)
        #   redirect_to admin_settings_path, notice: 'Permissions have been updated'
        # else
        #   redirect_to admin_settings_path, notice: 'Permissions have NOT been changed'
        # end
      end

      private

      def permissions
        @permissions ||= Permission.all
      end

      def firm
        @firm ||= Firm.find(params[:id])
      end

      def firm_params
        params.require(:firm).permit(permission_ids: [])
      end
    end
  end
end
