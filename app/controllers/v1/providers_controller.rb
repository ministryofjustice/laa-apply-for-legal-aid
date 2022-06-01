module V1
  class ProvidersController < ApiController
    def update
      provider = Provider.find_by(id: params[:id])
      action = params[:provider][:action]
      if provider && action
        provider.cookies_enabled = action == "accept"
        provider.save!

        render "", status: :ok
      else
        render "", status: :bad_request
      end
    end
  end
end
