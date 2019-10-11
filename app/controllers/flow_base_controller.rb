class FlowBaseController < ApplicationController
  include Flowable

  # This stops the browser caching these pages.
  # This is done so that someone can't use the Back button to return to a users pages
  # after they have logged out. There is a cost to page load speeds as a result
  def set_cache_buster
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end

  def merge_with_model(model, options = {})
    yield.tap do |hash|
      hash.merge! options if options.present?
      hash[:model] = model
    end
  end
end
