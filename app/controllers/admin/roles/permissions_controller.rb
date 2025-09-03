module Admin
  module Roles
    class PermissionsController < ApplicationController
      before_action :authenticate_admin_user!

      def show
        firm
        permissions
      end

      def update
        firm.update!(firm_params)
        redirect_to admin_root_path, notice: t(".notice")
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
        params.expect(firm: [permission_ids: []])
      end
    end
  end
end
