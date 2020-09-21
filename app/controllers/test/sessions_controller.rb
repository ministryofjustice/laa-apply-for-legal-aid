module Test
  class SessionsController < ApplicationController
    def create
      json_vars = params.permit(:session_vars)
      vars = JSON.parse(json_vars[:session_vars])
      vars.each do |var, value|
        session[var] = value
      end
      head :created
    end
  end
end
