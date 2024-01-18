module Citizens
  class BanksController < CitizenBaseController
    include Devise::Controllers::Rememberable

    def index
      remember_me(current_applicant)
      @ordered_banks = ordered_banks
    end

    def create
      @ordered_banks = ordered_banks

      if params[:provider_id].present?
        session[:provider_id] = params[:provider_id]
        session[:locale] = I18n.locale
        go_forward
      else
        @error = t(".error")
        render :index
      end
    end

  private

    def ordered_banks
      mock = TrueLayerBank.available_banks.select { |bank| bank[:display_name] == "Mock Bank" }
      real_banks = TrueLayerBank.available_banks.excluding(mock).sort_by { |bank| bank[:display_name].downcase }
      mock + real_banks
    end
  end
end
