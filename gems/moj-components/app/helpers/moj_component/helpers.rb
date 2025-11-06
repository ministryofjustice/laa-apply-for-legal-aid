# frozen_string_literal: true

module MojComponent
  module Helpers
    def moj_header(**kwargs, &block)
      render(MojComponent::HeaderComponent.new(**kwargs), &block)
    end

    def moj_interruption_card(**kwargs, &block)
      render(MojComponent::InterruptionCardComponent.new(**kwargs), &block)
    end

    def moj_sub_navigation(**kwargs, &block)
      render(MojComponent::SubNavigationComponent.new(**kwargs), &block)
    end
  end
end
