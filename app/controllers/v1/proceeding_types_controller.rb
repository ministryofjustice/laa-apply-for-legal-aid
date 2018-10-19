module V1
  class ProceedingTypesController < ApiController
    def index
      render json: ProceedingType.all
    end
  end
end
