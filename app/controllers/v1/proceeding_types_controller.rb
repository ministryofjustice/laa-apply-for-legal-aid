module V1
  class ProceedingTypesController < ApiController
    def index
      if params.key?(:search_term)
        search_term = params[:search_term]
        results = ProceedingTypeFullTextSearch.call(search_term, source_url)
        render json: results.to_json
      else
        render json: ProceedingType.all
      end
    end

    private

    def source_url
      params[:sourceUrl]
    end
  end
end
