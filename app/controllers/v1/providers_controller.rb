module V1
  class ProvidersController < ApiController
    ALLOWED_ACTIONS = %w[accept reject].freeze

    def update
      provider = Provider.find_by(id: params[:id])
      action = params[:provider][:action]
      if provider.nil? || ALLOWED_ACTIONS.exclude?(action)
        render "", status: :bad_request
      else
        provider.cookies_enabled = action == "accept"
        provider.cookies_saved_at = Time.zone.now
        provider.save!

        render "", status: :ok
      end
    end
  end
end
