class V1::ApplicationsController < ApplicationController
  def create
    application = LegalAidApplication.new
    proceeding_types_found = true

    if params[:proceeding_type_codes]
      proceeding_types_found = process_proceeding_types(application)
      application.proceeding_types << ProceedingType.where(code: params[:proceeding_type_codes])
    end

    if proceeding_types_found && application.save
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

  def process_proceeding_types(_application)
    proceeding_types_in_database = ProceedingType.where(code: params[:proceeding_type_codes])
    proceeding_types_in_database.size == params[:proceeding_type_codes].size
  end
end
