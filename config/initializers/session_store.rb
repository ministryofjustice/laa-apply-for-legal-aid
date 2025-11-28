# config/initializers/session_store.rb
# set secure: true, optionally only do this for certain Rails environments (e.g., Staging / Production
Rails.application.config.session_store :cookie_store,
                                       key: "_laa_apply_for_legal_aid_session",
                                       same_site: :none,
                                       secure: Rails.env.production?
