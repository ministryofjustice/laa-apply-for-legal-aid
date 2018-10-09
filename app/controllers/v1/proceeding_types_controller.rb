module V1
  class ProceedingTypesController < ApplicationController
    def index
      render json: ProceedingType.all
    end
  end
end
