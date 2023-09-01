module CookieBannerHelper
  def display_cookie_banner?(provider)
    provider.cookies_enabled.nil? || provider.cookies_saved_at.nil? || (provider.cookies_enabled && provider.cookies_saved_at < 1.year.ago)
  end
end
