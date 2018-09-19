module V1
  class ApplicantsController < ApplicationController
    before_action :set_application, only: [:update, :destroy]

    def index
      @applicant = Applicant.all
      render json: @applicant
    end

    def show
      @applicant = Applicant.find(params[:id])
      render json: @applicant
    end

    def create
      result = SaveApplicant.call(**applicant_params.to_h.symbolize_keys)

      if result.success?
        render json: ApplicantSerializer.new(result.applicant).serialized_json, status: :created
      else
        render json: result.errors, status: :bad_request
      end
    end

    def update
      applicant = @application.applicant
      if applicant.update(applicant_params)
        render json: ApplicantSerializer.new(applicant).serialized_json
      else
        render json: applicant.errors.full_messages, status: :bad_request
      end
    end

    def destroy
      @applicant.destroy
    end

    private

    def set_application
      @application = LegalAidApplication.find_by(application_ref: params[:application_ref])

      if @application.nil?
        render json: { message: "Failed to find application with ref #{params[:application_ref]}" }, status: :unprocessable_entity
      elsif @application.applicant.nil?
        render json: { message: "Failed to find applicant for application with ref #{params[:application_ref]}" }, status: :not_found
      end
    end

    def applicant_params
      params.require(:data).require(:attributes).permit(:first_name, :last_name, :date_of_birth, :application_ref, :email_address)
    end
  end
end
