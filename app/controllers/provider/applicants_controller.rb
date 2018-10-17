module Provider
  class ApplicantsController < ActionController::Base
    layout 'application'

    # GET /provider/legal_aid_applications/:legal_aid_application_id/applicant
    def show
      applicant
    end

    # GET /provider/legal_aid_applications/:legal_aid_application_id/applicant/new
    def new
      @applicant = legal_aid_application.build_applicant
    end

    # POST /provider/legal_aid_applications/:legal_aid_application_id/applicant
    def create
      @applicant = legal_aid_application.create_applicant(applicant_params)


      if applicant.save
        redirect_to [:provider, legal_aid_application, applicant], notice: 'Applicant was successfully created.'
      else
        render :new
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def applicant
        @applicant = legal_aid_application.applicant
      end

      def legal_aid_application
        @legal_aid_application ||= LegalAidApplication.find(params[:legal_aid_application_id])
      end

      # Only allow a trusted parameter "white list" through.
      def applicant_params
        params.require(:applicant).permit(
          :first_name, :last_name, :dob_day, :dob_month, :dob_year, :national_insurance_number
        ).tap do |hash|
          date_elements = [hash[:dob_day], hash[:dob_month], hash[:dob_year]]
          return if date_elements.any?(&:blank?)
          hash[:date_of_birth] = Time.parse(date_elements.join('-'))
          hash.delete_if { |k, _v| /dob_/ =~ k.to_s }
        end
      end
  end
end
