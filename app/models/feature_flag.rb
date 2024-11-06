class FeatureFlag < ApplicationRecord
  def self.method_missing(method)
    FeatureFlag.find_by(name: method)
  rescue ActiveRecord::RecordNotFound
    super
  end

  def self.respond_to_missing?(method, include_private = false)
    super
  end
end
