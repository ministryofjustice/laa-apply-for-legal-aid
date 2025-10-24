class ProviderSkippedAnnouncement < ApplicationRecord
  belongs_to :provider
  belongs_to :announcement
end
