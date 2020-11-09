# TODO: A temporary page to provide a starting point to the Provider journey
#       In the finished app, this page will be externally hosted
#       When this is removed the route `providers_root` will need to point at the external url
module Providers
  class StartController < ApplicationController
    before_action :update_locale
    def index; end
  end
end
