module AdminUsers
  class SessionsController < Devise::SessionsController
    def new
      @show_sign_in = !Rails.env.production?
      super
    end
  end
end
