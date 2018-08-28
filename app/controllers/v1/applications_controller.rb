class V1::ApplicationsController < ApplicationController
  def create
    application = LegalAidApplication.new

    if application.save
      render json: LegalAidApplicationSerializer.new(application).serialized_json, status: :created
    else
      render json: { status: 'ERROR', message: 'Failed to create application', data: application.errors }, status: :bad_request
    end
  end

  def show
    application = LegalAidApplication.find_by!(application_ref: params[:id])
    options = { include: [:applicant] }
    render json: LegalAidApplicationSerializer.new(application, options).serialized_json
  end
end
