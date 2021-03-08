module Admin
  class SettingsController < AdminBaseController
    def show
      @form = Settings::SettingForm.new(model: setting)
    end

    def update
      @form = Settings::SettingForm.new(form_params.merge(model: setting))

      if @form.save
        redirect_to admin_settings_path, notice: 'Settings have been updated'
      else
        render :show
      end
    end

    private

    def form_params
      params.require(:setting).permit(:mock_true_layer_data,
                                      :manually_review_all_cases,
                                      :allow_welsh_translation,
                                      :allow_multiple_proceedings,
                                      :override_dwp_results)
    end

    def setting
      Setting.first
    end
  end
end
