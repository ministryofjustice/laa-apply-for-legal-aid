class PrivacyPolicyController < ApplicationController
  include LocaleSwitchable
  before_action :update_locale
  def index; end
end
