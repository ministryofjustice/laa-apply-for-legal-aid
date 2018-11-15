module Providers
  class BaseController < ApplicationController
    before_action :authenticate_provider!
  end
end
