module PDA
  class ContractsCreator
    ApiError = Class.new(StandardError)

    def initialize(office_code)
      @office_code = office_code
    end

    def self.call(office_code)
      new(office_code).call
    end

    def call
      raise ApiError, "API Call Failed: (#{response.status}) #{response.body}" unless response.success?

      office.contracts.destroy_all
      if response.status == 200
        result = JSON.parse(response.body)
        result["contracts"].each do |contract|
          Contract.create!(office_id: office.id,
                           category_of_law: contract["categoryOfLaw"],
                           sub_category_of_law: contract["subCategoryOfLaw"],
                           authorisation_type: contract["authorisationType"],
                           new_matters: contract["newMatters"],
                           contractual_devolved_powers: contract["contractualDevolvedPosers"],
                           remainder_authorisation: contract["remainderAuthorisation"])
        end
      end
    end

  private

    def url
      @url ||= "#{Rails.configuration.x.pda.url}/provider-offices/#{@office_code}/office-contract-details"
    end

    def headers
      {
        "accept" => "application/json",
        "X-Authorization" => Rails.configuration.x.pda.auth_key,
      }
    end

    def conn
      @conn ||= Faraday.new(url:, headers:)
    end

    def response
      @response ||= query_api
    end

    def office
      @office = Office.find_by(code: @office_code)
    end

    def query_api
      conn.get url
    end
  end
end
