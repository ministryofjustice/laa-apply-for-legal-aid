module V1
  class ProceedingTypesController < ApiController
    def index
      search_term = params[:search_term]
      results = ProceedingTypeFullTextSearch.call(search_term)
      render json: results.to_json
    end
  end
end
