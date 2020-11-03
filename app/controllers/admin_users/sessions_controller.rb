module AdminUsers
  class SessionsController < Devise::SessionsController
    include JourneyTypeIdentifiable
    def new
      @show_sign_in = Rails.configuration.x.admin_portal.show_form
      super
    end
  end
end
