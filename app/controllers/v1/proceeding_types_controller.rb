module V1
  class ProceedingTypesController < ApiController
    def index
      if params.key?(:search_term)
        search_term = params[:search_term]
        results = ProceedingTypeFullTextSearch.call(search_term)
        render json: results.to_json
      else
        render json: ProceedingType.all
      end
    end
  end
end
