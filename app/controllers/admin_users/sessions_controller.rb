module AdminUsers
  class SessionsController < Devise::SessionsController
    def new
      @show_sign_in = Rails.configuration.x.admin_portal.show_form
      super
    end
  end
end
