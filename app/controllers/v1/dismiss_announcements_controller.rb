module V1
  class DismissAnnouncementsController < ApiController
    def create
      provider = current_provider
      ProviderDismissedAnnouncement.create!(provider:, announcement:)
      redirect_to return_to_param
    end

  private

    def return_to_param
      params.expect(:return_to)
    end

    def announcement
      Announcement.find(params.expect(:id))
    end
  end
end
