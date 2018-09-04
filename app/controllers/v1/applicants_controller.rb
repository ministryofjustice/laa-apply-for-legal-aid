class V1::ApplicantsController < ApplicationController
  before_action :set_applicant, only: [:show, :update, :destroy]

  def index
    @applicant = Applicant.all
    render json: @applicant
  end

  def show
    render json: @applicant
  end

  def create
    @applicant, success = SaveApplicant.call(name: params['data']['attributes']['name'], date_of_birth: params['data']['attributes']['date_of_birth'])
    if success
      redirect_to @applicant
    else
      render json: @applicant.errors, status: :unprocessable_entity
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
  .
  def set_applicant
    @applicant = Applicant.find(params[:id])
  end

  def applicant_params
    params.require(:applicant).permit(:name, :date_of_birth)
  end
end
