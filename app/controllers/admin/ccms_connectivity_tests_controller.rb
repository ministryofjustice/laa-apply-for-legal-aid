require 'rexml/document'

module Admin
  class CCMSConnectivityTestsController < AdminBaseController
    def show
      @response = ''
      xml = REXML::Document.new(CCMS::Requestors::ReferenceDataRequestor.new('my_login').call.to_s)
      xml.write(@response, 1)
      render :show
    end
  end
end
