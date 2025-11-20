module Admin
  class SettingsController < AdminBaseController
    def show
      @form = Settings::SettingForm.new(model: setting)
    end

    def update
      @form = Settings::SettingForm.new(form_params.merge(model: setting))
      @ccms_setting_changing = ccms_setting_changed?
      if @form.save
        CCMS::RestartSubmissions.call if ccms_restarting?
        redirect_to admin_settings_path, notice: t(".notice")
      else
        render :show
      end
    end

  private

    def form_params
      params.expect(setting: %i[mock_true_layer_data
                                manually_review_all_cases
                                allow_welsh_translation
                                enable_ccms_submission
                                collect_hmrc_data
                                collect_dwp_data
                                enable_datastore_submission])
    end

    def setting
      Setting.first
    end

    def ccms_restarting?
      @ccms_setting_changing && form_params["enable_ccms_submission"].eql?("true")
    end

    def ccms_setting_changed?
      @ccms_setting_changed ||= setting&.enable_ccms_submission?.to_s != form_params["enable_ccms_submission"]
    end
  end
end
