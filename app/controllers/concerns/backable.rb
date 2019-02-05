module Backable
  extend ActiveSupport::Concern
  HISTORY_SIZE = 20

  included do
    before_action :update_page_history

    # Adding ?back=true to the path of the previous page to indicate that we are moving backward in the page history
    def back_path
      return unless page_history.size > 1

      path = Addressable::URI.parse(page_history[-2])
      path.query_values = (path.query_values || {}).merge(back: true)
      path.to_s
    end
    helper_method :back_path

    private

    def update_page_history
      return unless request.request_method_symbol == :get

      if navigated_back?
        cleanup_path
      elsif flash[:back] == true
        page_history.pop
        flash[:back] = nil
      elsif !same_page?
        add_page_to_history
      end

      remove_old_history
    end

    def add_page_to_history
      page_history << request.fullpath
    end

    def navigated_back?
      params.key?(:back)
    end

    # removing "?back=true" param from the path
    def cleanup_path
      path = Addressable::URI.parse(request.fullpath)
      path.query_values = (path.query_values || {}).except('back')
      path.query_values = nil if path.query_values.empty?
      redirect_to path.to_s, flash: { back: true }
    end

    def same_page?
      page_history.last == request.fullpath
    end

    def remove_old_history
      page_history.shift while page_history.size > HISTORY_SIZE
    end

    def page_history
      session[:page_history] ||= []
    end
  end
end
