module MojComponent
  class SubNavigationComponent < ViewComponent::Base
    renders_many :navigation_items, "NavigationItem"

    class NavigationItem < ViewComponent::Base
      attr_reader :text, :href, :current

      def initialize(text:, href: "#", current: nil)
        @text = text
        @href = href
        @current = current
        super
      end

      def call
        tag.li class: "moj-sub-navigation__item" do
          link_to(text, href, class: "moj-sub-navigation__link", aria: current_override)
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
