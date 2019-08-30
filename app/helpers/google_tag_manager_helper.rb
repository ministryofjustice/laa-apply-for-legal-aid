module GoogleTagManagerHelper
  def google_tag_present?
    Rails.configuration.x.google_tag_manager_tracking_id.present?
  end
end
