class FeatureFlag < ApplicationRecord
  def self.method_missing(method)
    if method.ends_with?("?")
      FeatureFlag.find_by(name: method.to_s.chop)&.on?
    else
      FeatureFlag.find_by(name: method)
    end
  rescue ActiveRecord::RecordNotFound
    super
  end

  def self.respond_to_missing?(method, include_private = false)
    super
  end

  def state
    if active.nil?
      if Time.zone.now > start_at
        :active
      else
        "Scheduled to go live at #{start_at.strftime('%H:%M')} on #{start_at.strftime('%e %B %Y')}"
      end
    else
      active? ? :active : :inactive
    end
  end

  def on?
    if active.nil?
      Time.zone.now > start_at
    else
      active == true
    end
  end
end
