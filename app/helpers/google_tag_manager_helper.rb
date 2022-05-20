module GoogleTagManagerHelper
  def cookies_enabled?
    current_provider_enabled_cookies? && google_tag_present?
  end

private

  def current_provider_enabled_cookies?
    current_provider? && opted_in?
  end

  def current_provider?
    current_provider
  end

  def opted_in?
    current_provider.cookies_enabled?
  end

  def google_tag_present?
    Rails.configuration.x.google_tag_manager_tracking_id.present?
  end
end
