module Admin
  class SettingsController < AdminBaseController
    def show
      @form = Settings::SettingForm.new(model: setting)
    end

    def update
      @form = Settings::SettingForm.new(form_params.merge(model: setting))

      CCMS::RestartSubmissions.call if ccms_restarting?
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
                                      :enable_ccms_submission,
                                      :enable_employed_journey)
    end

    def setting
      Setting.first
    end

    def ccms_restarting?
      ccms_setting_changed? && form_params['enable_ccms_submission'].eql?('true')
    end

    def ccms_setting_changed?
      setting&.enable_ccms_submission?.to_s != form_params['enable_ccms_submission']
    end
  end
end
