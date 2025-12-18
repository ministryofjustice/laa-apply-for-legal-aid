class Announcement < ApplicationRecord
  enum :display_type, { gov_uk: 0, moj: 1 }

  has_many :provider_dismissed_announcements, dependent: :delete_all

  validates :heading, presence: true, if: ->(announcement) { announcement.display_type == "gov_uk" }
  validates :body, presence: true, if: ->(announcement) { announcement.display_type == "moj" }
  validates :display_type, :start_at, :end_at, presence: true
  validates :link_url, presence: true, if: ->(announcement) { announcement.link_display.present? }
  validates :link_display, presence: true, if: ->(announcement) { announcement.link_url.present? }
  validates :start_at, :end_at, date_time: ->(field) { announcement.send(field).present? }

  scope :active, -> { where(start_at: ...Time.current, end_at: Time.current...) }

  def active?
    Time.zone.now >= start_at.to_time && Time.zone.now < end_at.to_time
  end
end
