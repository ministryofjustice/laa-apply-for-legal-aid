require 'rexml/document'

module Admin
  class CcmsConnectivityTestsController < AdminBaseController
    def show
      @response = ''
      xml = REXML::Document.new(CCMS::Requestors::ReferenceDataRequestor.new('my_login').call.to_s)
      xml.write(@response, 1)
      render :show
    end
  end
end
