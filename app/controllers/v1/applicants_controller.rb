require 'save_applicant'

class V1::ApplicantsController < ApplicationController
    before_action :set_applicant, only: [:show, :update, :destroy]

    # GET /citizens
    def index
      @applicant = Applicant.all
      render json: @applicant
    end

    # GET /citizens/1
    def show
      render json: @applicant
    end

    # POST /citizens
    # def create
    #   @applicant = Applicant.new(applicant_params)
    #
    #   if @applicant.save
    #     render json: @applicant, status: :created, location: @applicant
    #   else
    #     render json: @applicant.errors, status: :unprocessable_entity
    #   end
    # end

    def create
      @applicant , success = SaveApplicant.new.save_applicant(name: params["data"]["attributes"]["name"] , date_of_birth: params["data"]["attributes"]["date_of_birth"] )
      if success
        redirect_to @applicant
      else
        render json: @applicant.errors, status: :unprocessable_entity
      end
    end


    # PATCH/PUT /citizens/1
    def update
      if @applicant.update(applicant_params)
        render json: @applicant
      else
        render json: @applicant.errors.messages, status: :unprocessable_entity
      end
    end

    # DELETE /citizens/1
    def destroy
      @applicant.destroy
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_applicant
        @applicant = Applicant.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def applicant_params
        params.require(:applicant).permit(:name, :date_of_birth)
      end

end
