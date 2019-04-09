class ApplicationController < ActionController::Base
  layout 'application'
  include Backable

  rescue_from ActiveRecord::RecordNotFound, with: :page_not_found

  private

  def page_not_found
    redirect_to error_path(:page_not_found)
  end
end
