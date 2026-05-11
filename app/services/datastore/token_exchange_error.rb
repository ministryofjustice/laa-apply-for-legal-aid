module Datastore
  class TokenExchangeError < StandardError
    attr_reader :response

    def initialize(response)
      @response = response

      super(
        [
          "Microsoft token exchange failed",
          response["error"],
          response["error_description"],
        ].compact.join(": ")
      )
    end
  end
end
