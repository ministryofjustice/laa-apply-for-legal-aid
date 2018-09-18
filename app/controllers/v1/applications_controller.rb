class V1::ApplicationsController < ApplicationController
  def create
    application = LegalAidApplication.new

    if params[:proceeding_type_codes]
      valid_proceeding_types = validate_proceeding_types(application)
      return render json: { status: 'ERROR', message: 'Invalid proceeding types', data: application.errors }, status: :bad_request unless valid_proceeding_types
    end

    if application.save
      render json: LegalAidApplicationSerializer.new(application).serialized_json, status: :created
    else
      render json: { status: 'ERROR', message: 'Failed to create application', data: application.errors }, status: :bad_request
    end
  end

  def show
    application = LegalAidApplication.find_by!(application_ref: params[:ref])
    options = { include: [:applicant] }
    render json: LegalAidApplicationSerializer.new(application, options).serialized_json
  end

  private

  def validate_proceeding_types(application)
    proceedings = ProceedingType.where(code: params[:proceeding_type_codes])
    all_found = proceedings.size == params[:proceeding_type_codes].size
    application.proceeding_types = proceedings if all_found
    all_found
  end
end
