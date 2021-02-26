module V1
  class ProceedingTypesController < ApiController
    def index
      search_term = params[:search_term]
      @search = ProceedingTypeFullTextSearch.new(search_term)
      results = @search.call
      render json: results.to_json
    end
  end
end
