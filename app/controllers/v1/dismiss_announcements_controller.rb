module V1
  class DismissAnnouncementsController < ApiController
    def destroy
      provider = current_provider
      ProviderDismissedAnnouncement.create!(provider:, announcement:)
      redirect_to strong_params[:return_to]
    end

  private

    def strong_params
      params.permit(:id, :return_to)
    end

    def announcement
      Announcement.find(strong_params[:id])
    end
  end
end
