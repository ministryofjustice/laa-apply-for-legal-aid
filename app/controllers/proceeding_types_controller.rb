class ProceedingTypesController < ApplicationController
  def index
    proceeding_types = ProceedingType.all
    render json: ProceedingTypesSerializer.new(proceeding_types).serialized_json
  end
end
