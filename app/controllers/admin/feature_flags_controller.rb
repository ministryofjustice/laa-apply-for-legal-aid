module Admin
  class FeatureFlagsController < AdminBaseController
    before_action :feature_flag, only: %i[show update]

    def index
      @feature_flags = FeatureFlag.all
    end

    def show; end

    def update
      feature_flag.update!(flag_params)
      redirect_to admin_feature_flags_path if feature_flag.valid? && feature_flag.save!
    rescue ActiveRecord::MultiparameterAssignmentErrors
      render :show
    end

    def feature_flag
      @feature_flag ||= FeatureFlag.find(params[:id])
    end

    def flag_params
      params.require(:feature_flag).permit(:start_at, :active)
    end
  end
end
