class ProviderDismissedAnnouncement < ApplicationRecord
  belongs_to :provider
  belongs_to :announcement
end
