class V1::ApplicationsController < ApplicationController
  def create
    application = LegalAidApplication.new

    if params[:proceeding_type_codes]
      match_found = ProceedingTypeService.new.process_proceeding_type(params[:proceeding_type_codes], application)
      return render json: { status: 'ERROR', message: 'Invalid proceeding types', data: application.errors }, status: :bad_request unless match_found
    end

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
