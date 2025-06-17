module Providers
  class StartController < ApplicationController
    before_action :update_locale
    skip_before_action :authenticate_provider!, only: :index

    def index; end
  end
end
