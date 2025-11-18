# frozen_string_literal: true

module MojComponent
  class AlertComponent < ApplicationComponent
    attr_reader :type,
                :heading,
                :body,
                :dismiss_href,
                :dismiss_text,
                :dismiss_method

    def initialize(type:, heading:, body:, dismiss_href:, dismiss_text: "Dismiss", dismiss_method: :post)
      @type = check_type(type)
      @heading = heading
      @body = body
      @dismiss_href = dismiss_href
      @dismiss_text = dismiss_text
      @dismiss_method = dismiss_method
      super()
    end

  private

    def check_type(type)
      raise ArgumentError, "type must be :information, :success, :warning or :error" unless type.in?(%i[information success warning error])

      type
    end
  end
end
