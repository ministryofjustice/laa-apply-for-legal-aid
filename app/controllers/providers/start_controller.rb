module Providers
  class StartController < ApplicationController
    before_action :update_locale
    skip_back_history_for :index

    def index; end
  end
end
