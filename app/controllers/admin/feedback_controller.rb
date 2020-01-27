module Admin
  class FeedbackController < ApplicationController
    include Pagy::Backend
    before_action :authenticate_admin_user!
    layout 'admin'.freeze

    DEFAULT_PAGE_SIZE = 10

    # GET /admin/feedback
    def show
      @pagy, @feedback = pagy(
        Feedback.all,
        items: params.fetch(:page_size, DEFAULT_PAGE_SIZE),
        size: [1, 1, 1, 1]
      )
    end
  end
end
