module Admin
  class SiteBannersController < AdminBaseController
    def index
      @messages = Announcement.all
    end

    def show
      @announcement = announcement
    end

    def new
      @announcement = Announcement.new
    end

    def create
      @announcement = Announcement.new(form_params[:announcement])
      if @announcement.valid?
        @announcement.save!
        redirect_to action: :index
      else
        render :new
      end
    end

    def update
      @announcement = announcement
      @announcement.update!(form_params[:announcement])
      redirect_to action: :index
    rescue StandardError
      render :show
    end

    def destroy
      announcement.destroy!
      redirect_to action: :index
    end

  private

    def announcement
      Announcement.find(params[:id])
    end

    def form_params
      params.permit(announcement: %i[display_type gov_uk_header_bar link_display link_url heading body start_at end_at])
    end
  end
end
