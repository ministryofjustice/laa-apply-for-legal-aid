module V1
  class ApplicantsController < ApiController
    def show
      @applicant = Applicant.find(params[:id])
      render json: @applicant
    end

    def create
      applicant = application.build_applicant(applicant_params)

      if applicant.save
        render json: applicant, status: :created
      else
        render_400 applicant.errors
      end
    end

    def update
      if applicant.update(applicant_params)
        render json: applicant
      else
        render_400 applicant.errors
      end
    end

    private

    def application
      @application ||= LegalAidApplication.find_by!(application_ref: params[:application_id])
    end

    def applicant
      @applicant ||= application.applicant || raise(ActiveRecord::RecordNotFound)
    end

    def applicant_params
      params.require(:applicant).permit(:first_name, :last_name, :date_of_birth, :email_address, :national_insurance_number)
    end
  end
end
