class ApplicationController < ActionController::Base
  layout 'application'
  include Backable

  # See also catch all route at end of config/routes.rb
  rescue_from ActiveRecord::RecordNotFound, with: :page_not_found

  private

  def page_not_found
    redirect_to error_path(:page_not_found)
  end
end
