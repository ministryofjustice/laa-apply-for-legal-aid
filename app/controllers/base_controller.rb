class BaseController < ApplicationController
  include Flowable

  def merge_with_model(model, options = {})
    yield.tap do |hash|
      hash.merge! options if options.present?
      hash[:model] = model
    end
  end
end
