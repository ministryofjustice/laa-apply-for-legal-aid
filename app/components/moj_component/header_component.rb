# frozen_string_literal: true

module MojComponent
  class HeaderComponent < ViewComponent::Base
    renders_many :navigation_items, "NavigationItem"

    attr_reader :organisation_name,
                :url,
                :nav_items

    def initialize(organisation_name:, url:)
      @organisation_name = organisation_name
      @url = url
      super
    end

    class NavigationItem < ViewComponent::Base
      attr_reader :text, :href, :current, :options

      def initialize(text:, href: nil, current: nil, options: {})
        @text = text
        @href = href
        @current = current
        @options = options
        super
      end

      def call
        tag.li class: "moj-header__navigation-item" do
          link_to(text, href, class: "moj-header__navigation-link", aria: current_override, **options)
        end
      end

    private

      def current_override
        if current
          { current: "page" }
        end
      end
    end
  end
end
