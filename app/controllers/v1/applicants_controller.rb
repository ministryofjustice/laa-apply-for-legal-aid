module V1
  class ApplicantsController < ApplicationController
    before_action :set_applicant, only: [:show, :update, :destroy]

    def index
      @applicant = Applicant.all
      render json: @applicant
    end

    def show
      render json: @applicant
    end

    def create
      result= SaveApplicant.call(**applicant_params.to_h.symbolize_keys)
      result.success?
      if success
        render json: ApplicantSerializer.new(result.).serialized_json, status: :created
      else
        render json: result.errors, status: :bad_request
      end
    end

    def update
      if @applicant.update(applicant_params)
        render json: @applicant
      else
        render json: @applicant.errors.messages, status: :unprocessable_entity
      end
    end

    def destroy
      @applicant.destroy
    end

    private

    def set_applicant
      @applicant = Applicant.find(params[:id])
    end

    def applicant_params
      params.require(:data).require(:attributes).permit(:name, :date_of_birth, :application_ref)
    end
  end
end
