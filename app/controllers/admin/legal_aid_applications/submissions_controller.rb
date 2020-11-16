module Admin
  module LegalAidApplications
    class SubmissionsController < ApplicationController
      before_action :authenticate_admin_user!
      layout 'admin'.freeze

      def show
        @legal_aid_application = LegalAidApplication.find(params[:id])
      end
    end
  end
end
