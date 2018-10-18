module V1
  class CryptController < ApplicationController
    def create
      text = crypt.decrypt(params[:token])
      render json: { text: text }
    end

    def crypt
      @crypt ||= Crypt.new
    end
  end
end
