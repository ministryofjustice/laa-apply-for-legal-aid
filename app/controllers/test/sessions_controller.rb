module Test
  # This controller is used purely for setting session variables for RSpec request spec.
  # Use with the #set_session method defined in spec/rails_helper.rb
  #
  # The test_session_path route is defined in test environment only
  #
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
