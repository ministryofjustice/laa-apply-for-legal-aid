module Providers
  module ApplicantDependable
    extend ActiveSupport::Concern

    included do
      before_action :set_applicant

      def applicant
        @applicant ||= Applicant.find_by(id: params[:applicant_id])
      end

      def set_applicant
        return if applicant.present?

        flash[:error] = 'Invalid applicant'
        redirect_to providers_legal_aid_applications_path
      end
    end
  end
end
