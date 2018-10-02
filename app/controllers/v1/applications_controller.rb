class V1::ApplicationsController < ApplicationController
  def create
    application = LegalAidApplication.new(application_params)

    if application.save
      render json: application, status: :created
    else
      render_400 application.errors
    end
  end

  def show
    application = LegalAidApplication.find_by!(application_ref: params[:id])
    render json: application
  end

  private

  def application_params
    # NOTE: [] tells permit that proceeding_type_codes accepts
    # an array as the value. Otherwise, permit will ignore the
    # that input
    params.permit(proceeding_type_codes: [])
  end
end
