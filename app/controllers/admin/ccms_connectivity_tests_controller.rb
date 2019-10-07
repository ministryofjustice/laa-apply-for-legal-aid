require 'rexml/document'

module Admin
  class CcmsConnectivityTestsController < ApplicationController
    before_action :authenticate_admin_user!
    layout 'admin'.freeze

    def show
      @response = ''
      xml = REXML::Document.new(CCMS::ReferenceDataRequestor.new('my_login').call.to_s)
      xml.write(@response, 1)
      render :show
    end
  end
end
