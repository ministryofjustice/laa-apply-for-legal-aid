class V1::ProceedingTypesController < ApplicationController

  def index
    proceeding_types = ProceedingType.all
    render json: ProceedingTypesSerializer.new( proceeding_types).serialized_json, status: :ok
  end

end
