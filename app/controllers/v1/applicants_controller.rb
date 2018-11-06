module V1
  class ApplicantsController < ApiController
    def create
      applicant = application.build_applicant(applicant_params)

      if applicant.save
        render json: applicant, status: :created
      else
        render_400 applicant_errors
      end
    end

    def update
      if applicant.update(applicant_params)
        render json: applicant
      else
        render_400 applicant_errors
      end
    end

    private

    def applicant_errors
      applicant.errors.details[:email_address] = applicant.errors.details.delete(:email) if applicant.errors.details[:email]
      applicant.errors
    end

    def application
      @application ||= LegalAidApplication.find_by!(application_ref: params[:application_id])
    end

    def applicant
      @applicant ||= application.applicant || raise(ActiveRecord::RecordNotFound)
    end

    def applicant_params
      params[:applicant][:email] = params.dig(:applicant, :email_address) if params[:applicant]
      params.require(:applicant)
            .permit(:first_name, :last_name, :email, :date_of_birth, :national_insurance_number)
    end
  end
end
