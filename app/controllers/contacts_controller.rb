class ContactsController < ApplicationController
  include LocaleSwitchable
  before_action :update_locale
  def show; end
end
