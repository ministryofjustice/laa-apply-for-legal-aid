module Backable
  extend ActiveSupport::Concern

  HISTORY_SIZE = 20
  EXCLUDED_BACK_PATHS = %w[statement_of_case_upload/list].freeze

  class_methods do
    def skip_back_history_actions
      @skip_back_history_actions || []
    end

    def skip_back_history_for(*actions)
      @skip_back_history_actions = actions.map(&:to_sym)
    end
  end

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

    def replace_last_page_in_history(path)
      return if page_history.empty?

      temp_page_history = page_history
      temp_page_history[-1] = path
      page_history_service.write(temp_page_history)
    end

  private

    def update_page_history
      return if self.class.skip_back_history_actions.include?(action_name.to_sym)
      return unless request.request_method_symbol == :get

      process_history
      remove_old_history
    end

    def process_history
      if navigated_back?
        cleanup_path
      elsif flash[:back] == true
        temp_page_history = page_history
        temp_page_history.pop
        page_history_service.write(temp_page_history)
        flash[:back] = nil
      elsif !same_page?
        add_page_to_history
      end
    end

    def add_page_to_history
      return if EXCLUDED_BACK_PATHS.any? { |path| request.fullpath.include? path }

      page_history_service.write(page_history << request.fullpath)
    end

    def navigated_back?
      params.key?(:back)
    end

    # removing "?back=true" param from the path
    def cleanup_path
      path = Addressable::URI.parse(request.fullpath)
      path.query_values = (path.query_values || {}).except("back")
      path.query_values = nil if path.query_values.empty?
      redirect_to path.to_s, flash: { back: true }
    end

    def same_page?
      page_history.last == request.fullpath
    end

    def remove_old_history
      page_history_service.write(page_history.last(HISTORY_SIZE))
    end

    def page_history
      history = page_history_service.read
      return [] if history.nil?

      JSON.parse(history)
    rescue JSON::ParserError => e
      Rails.logger.error("#{self.class.name} page_history JSON parse error: #{e.message}")
      []
    end

    def page_history_service
      @page_history_service ||= PageHistoryService.new(page_history_id:)
    end

    def page_history_id
      @page_history_id ||= session[:page_history_id]
    end
  end
end
