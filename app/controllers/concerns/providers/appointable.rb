module Providers
  module Appointable
    extend ActiveSupport::Concern

    # Redirects to the office selection page if there is no `selected_office`,
    # remembering wheree the user/provider came from. The office select controller
    # will then redirect back to the remebered location or home page for provider
    #
    # Example:
    #
    #   before_action :appoint_provider!
    #
    def appoint_provider!
      return if current_provider.selected_office.present? || allowed_unappointed_path?

      store_location_for(:provider, request.fullpath)
      redirect_to providers_select_office_path
    end

    # Stores the provided location to redirect the user after selecting an office.
    # Useful in combination with the `stored_location_for` helper.
    #
    # Example:
    #
    #   store_location_for(:provider, home_path)
    #   redirect_to providers_select_office_path
    #
    def store_location_for(resource_or_scope, location)
      session_key = stored_location_key_for(resource_or_scope)

      path = extract_path_from_location(location)
      session[session_key] = path if path
    end

    # Returns and deletes the url stored in the session for
    # the given scope. Useful for giving redirect backs after office selection:
    #
    # Example:
    #
    #   redirect_to stored_location_for(:user) || root_path
    #
    def stored_location_for(resource_or_scope)
      session_key = stored_location_key_for(resource_or_scope)

      session.delete(session_key)
    end

  private

    def allowed_unappointed_path?
      request.fullpath.in? [
        providers_select_office_path,
        providers_invalid_schedules_path,
        providers_provider_path,
      ]
    end

    def parse_uri(location)
      location && URI.parse(location)
    rescue URI::InvalidURIError
      nil
    end

    def stored_location_key_for(resource_or_scope)
      scope = Devise::Mapping.find_scope!(resource_or_scope)
      "#{scope}_select_office_return_to"
    end

    def extract_path_from_location(location)
      uri = parse_uri(location)

      if uri
        path = remove_domain_from_uri(uri)
        add_fragment_back_to_path(uri, path)

      end
    end

    def remove_domain_from_uri(uri)
      [uri.path.sub(/\A\/+/, "/"), uri.query].compact.join("?")
    end

    def add_fragment_back_to_path(uri, path)
      [path, uri.fragment].compact.join("#")
    end
  end
end
